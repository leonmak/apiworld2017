//
//  HTView.swift
//  HyperTrack
//
//  Created by Vibes on 5/24/17.
//  Copyright © 2017 HyperTrack. All rights reserved.
//

import UIKit
import MapKit

class HTView: HTCommonView {
    
    @IBOutlet weak var statusCard: UIView!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var eta: UILabel!
    @IBOutlet weak var distanceLeft: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var cardConstraint: NSLayoutConstraint!
    @IBOutlet weak var tripIcon: UIImageView!
    @IBOutlet weak var destinationTitle: UILabel!
    
    var searchView : HTPlacePickerView?
    
    @IBOutlet weak var touchView: UIView!
    
    var progressCircle = CAShapeLayer()
    var currentProgress : Double = 0
    var expandedCard : ExpandedCard? = nil
    var downloadedPhotoUrl : URL? = nil
    var statusCardEnabled = true
    
    var previousCount = 0
    
    var currentSelectedIndexPath : IndexPath?
    var currentVisibleIndex = 0
    var numberOfItemsInCarousel = 0
    var selectedHypertrackPlace : HyperTrackPlace?
    var isDestinationViewEmpty = true
    
    var isPhoneButtonShown = true
    var destinationPlace : HyperTrackPlace? = nil
    
    func initMapView(mapSubView: MKMapView, interactionViewDelegate: HTViewInteractionInternalDelegate) {
        
        self.mapView.addSubview(mapSubView)
        self.interactionViewDelegate = interactionViewDelegate
        self.clearView()
        self.mapProvider?.mapCustomizationDelegate = self
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDestinationTap(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        self.destinationView.addGestureRecognizer(singleTap)
        
    }
    
    override func awakeFromNib() {
        destinationView.shadow()
        statusCard.shadow()
        addProgressCircle()
        addExpandedCard()
        self.statusCard.isHidden = false
        self.destination.text = ""
    }
    
    
    override func zoomMapTo(visibleRegion: MKCoordinateRegion, animated: Bool){
        self.mapProvider?.zoomTo(visibleRegion: visibleRegion, animated: true)
    }
    
    func handleDestinationTap(_ sender: UITapGestureRecognizer) {
        if(isDestinationEditable){
            showSearchView()
        }
    }
    
    func showSearchView(){
        let bundle = Settings.getBundle()!
        self.searchView  = bundle.loadNibNamed("LocationPickerView", owner: self, options: nil)?.first as? HTPlacePickerView
        self.searchView?.pickerViewDelegate = self
        self.searchView?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.searchView?.startLocation = self.destinationPlace
        self.searchView?.setUpView()
        self.addSubview((self.searchView)!)
        self.bringSubview(toFront: (self.searchView)!)
        self.searchView?.setUp()
        self.clipsToBounds = true
    }
    
    func hideSearchView(){
        self.searchView?.removeFromSuperview()
    }
    
    
    @IBAction func phone(_ sender: Any) {
        if(isPhoneButtonShown){
            self.interactionViewDelegate?.didTapPhoneButton?(sender)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.interactionViewDelegate?.didTapBackButton?(sender)
    }
    
    @IBAction func reFocus(_ sender: Any) {
        self.interactionViewDelegate?.didTapReFocusButton?(sender)
    }
    
    @IBAction func expandCard(_ sender: Any) {
        
        if !isCardExpanded {
            
            UIView.animate(withDuration: 0.2, animations: {
                self.cardConstraint.constant = 160
                self.arrow.transform = CGAffineTransform(rotationAngle: 1.57)
                self.layoutIfNeeded()
            })
            
            isCardExpanded = true
        } else {
            
            UIView.animate(withDuration: 0.2, animations: {
                self.cardConstraint.constant = 20
                self.arrow.transform = CGAffineTransform(rotationAngle: 0)
                self.layoutIfNeeded()
            })
            
            isCardExpanded = false
        }
    }
    
    override func updateAddressView(isAddressViewShown: Bool, destinationAddress: String? ,action:HyperTrackAction) {
        if isAddressViewShown {
            self.destination.text = destinationAddress
            self.destinationView.isHidden = false
            self.destinationTitle.text = "Destination"
            isDestinationViewEmpty = false
            
        } else {
            self.destinationView.isHidden = true
            self.destination.text = "Add a Destination"
            self.destinationTitle.text = "Going somewhere ?"
            isDestinationViewEmpty = true
        }
    }
    
    override func updateInfoView(statusInfo : HTStatusCardInfo){
        if !statusInfo.isInfoViewShown {
            self.statusCard.isHidden = true
            return
        }
        
        self.statusCard.isHidden = false
        var progress: Double = 1.0
        
        if (statusInfo.showActionDetailSummary) {
            // Update eta & distance data
            self.eta.text = "\(Int(statusInfo.timeElapsedMinutes)) min"
            self.distanceLeft.text = "\(statusInfo.distanceCovered) \(statusInfo.distanceUnit)"
            
            if (statusInfo.distanceLeft != nil) {
                progress = statusInfo.distanceCovered / (statusInfo.distanceCovered + statusInfo.distanceLeft!)
            }
            
        } else {
            if (statusInfo.eta != nil) {
                self.eta.text = "\(Int(statusInfo.eta!)) min"
            } else {
                self.eta.text = " "
            }
            
            if (statusInfo.distanceLeft != nil) {
                if (eta != nil) {
                    self.distanceLeft.text = "(\(statusInfo.distanceLeft!) \(statusInfo.distanceUnit))"
                } else {
                    self.distanceLeft.text = "\(statusInfo.distanceLeft!) \(statusInfo.distanceUnit)"
                }
            } else {
                self.distanceLeft.text = ""
            }
        }
        
        if (statusInfo.distanceLeft != nil) {
            progress = statusInfo.distanceCovered / (statusInfo.distanceCovered + statusInfo.distanceLeft!)
        }
        
        self.status.text = statusInfo.status
        animateProgress(to: progress)
        
        UIView.animate(withDuration: 0.15) {
            self.layoutIfNeeded()
        }
        
        if let expandedCard = self.expandedCard {
            
            expandedCard.name.text = statusInfo.userName
            
            if let photo = statusInfo.photoUrl {
                if (self.downloadedPhotoUrl == nil) || (self.downloadedPhotoUrl != photo) {
                    expandedCard.photo.image = getImage(photoUrl: photo)
                }
            }
            
            if (statusInfo.showActionDetailSummary) {
                self.completeActionView(startTime: statusInfo.startTime, endTime: statusInfo.endTime,
                                        origin: statusInfo.startAddress, destination: statusInfo.completeAddress,
                                        timeElapsed: statusInfo.timeElapsedMinutes,
                                        distanceCovered: statusInfo.distanceCovered,
                                        showExpandedCardOnCompletion: statusInfo.showExpandedCardOnCompletion)
            } else {
                let timeInSeconds = Int(statusInfo.timeElapsedMinutes * 60.0)
                let hours = timeInSeconds / 3600
                let minutes = (timeInSeconds / 60) % 60
                let seconds = timeInSeconds % 60
                
                expandedCard.timeElapsed.text = String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
                expandedCard.distanceTravelled.text = "\(statusInfo.distanceCovered) \(statusInfo.distanceUnit)"
                
                if (statusInfo.speed != nil) {
                    if (statusInfo.distanceUnit == "mi") {
                        expandedCard.speed.text = "\(statusInfo.speed!) mph"
                    } else {
                        expandedCard.speed.text = "\(statusInfo.speed!) kmph"
                    }
                } else {
                    expandedCard.speed.text = "--"
                }
                
                if (statusInfo.battery != nil) {
                    expandedCard.battery.text = "\(Int(statusInfo.battery!))%"
                } else {
                    expandedCard.battery.text = "--"
                }
                
                let lastUpdatedMins = Int(-1 * Double(statusInfo.lastUpdated.timeIntervalSinceNow) / 60.0)
                
                if (lastUpdatedMins < 1) {
                    expandedCard.lastUpdated.text = "Last updated: few seconds ago"
                } else {
                    expandedCard.lastUpdated.text = "Last updated: \(lastUpdatedMins) min ago"
                }
            }
        }
        
    }
    
    func getImage(photoUrl: URL) -> UIImage? {
        do {
            let imageData = try Data.init(contentsOf: photoUrl, options: Data.ReadingOptions.dataReadingMapped)
            self.downloadedPhotoUrl = photoUrl
            return UIImage(data:imageData)
        } catch let error {
            HTLogger.shared.error("Error in fetching photo: " + error.localizedDescription)
            return nil
        }
    }
    
    private func completeActionView(startTime: Date?, endTime: Date?,
                                    origin: String?, destination: String?,
                                    timeElapsed: Double, distanceCovered: Double,
                                    showExpandedCardOnCompletion: Bool) {
        guard statusCardEnabled else { return }
        
        let bundle = Settings.getBundle()!
        let completedView: CompletedView = bundle.loadNibNamed("CompletedView", owner: self, options: nil)?.first as! CompletedView
        completedView.alpha = 0
        
        self.statusCard.addSubview(completedView)
        self.statusCard.bringSubview(toFront: completedView)
        self.statusCard.bringSubview(toFront: phoneButton)
        
        completedView.frame = CGRect(x: 0, y: 90, width: self.statusCard.frame.width, height: 155)
        
        self.statusCard.clipsToBounds = true
        
        completedView.completeUpdate(startTime: startTime, endTime: endTime, origin: origin, destination: destination)
        
        self.touchView.isHidden = true
        self.isCardExpanded = true
        
        UIView.animate(withDuration: 0.2, animations: {
            self.cardConstraint.constant = 160
            completedView.alpha = 1
            self.arrow.alpha = 0
            self.layoutIfNeeded()
        })
        
    }
    
    override func updateReFocusButton(isRefocusButtonShown: Bool) {
        self.reFocusButton.isHidden = !isRefocusButtonShown
    }
    
    override func updateBackButton(isBackButtonShown: Bool) {
        self.backButton.isHidden = !isBackButtonShown
    }
    
    override func updatePhoneButton(isPhoneShown: Bool) {
        self.isPhoneButtonShown = isPhoneShown
        if(isPhoneShown){
            let bundle = Settings.getBundle()!
            if let image = UIImage.init(named: "phone", in: bundle, compatibleWith: nil){
                self.phoneButton.setBackgroundImage(image, for: UIControlState.normal)
            }
        }else{
            let bundle = Settings.getBundle()!
            if let image = UIImage.init(named: "jetpack", in: bundle, compatibleWith: nil){
                self.phoneButton.setBackgroundImage(image, for: UIControlState.normal)
            }
        }
    }
    
    override func clearView() {
        //self.destinationView.isHidden = true
        self.statusCard.isHidden = true
        self.reFocusButton.isHidden = true
    }
    
    override func clearMap(){
        self.mapProvider?.clearMap()
    }
    
    override func updatePolyline(polyline: String){
        self.mapProvider?.updatePolyline(polyline: polyline)
    }
    
    override  func updatePolyline(polyline: String,startMarkerImage:UIImage?){
        self.mapProvider?.updatePolyline(polyline: polyline, startMarkerImage: startMarkerImage)
    }
    
    
    override func updateDestinationMarker(showDestination: Bool, destinationAnnotation: HTMapAnnotation?,place : HyperTrackPlace?){
        self.destinationPlace = place
        self.mapProvider?.updateDestinationMarker(showDestination: showDestination, destinationAnnotation: destinationAnnotation)
    }
    
    override func updateHeroMarker(userId: String, actionID: String, heroAnnotation: HTMapAnnotation, disableHeroMarkerRotation: Bool){
        self.mapProvider?.updateHeroMarker(userId: userId, actionID: actionID, heroAnnotation: heroAnnotation
            , disableHeroMarkerRotation: disableHeroMarkerRotation)
    }
    
    override func animateMarker(userId: String, locations: [CLLocationCoordinate2D], currentIndex: Int, duration: TimeInterval, disableHeroMarkerRotation: Bool){
        self.mapProvider?.animateMarker(userId: userId, locations: locations, currentIndex: currentIndex, duration: duration, disableHeroMarkerRotation: disableHeroMarkerRotation)
    }
    
    override func reFocusMap(isInfoViewCardExpanded: Bool, isDestinationViewVisible: Bool){
        self.mapProvider?.reFocusMap(isInfoViewCardExpanded: isInfoViewCardExpanded, isDestinationViewVisible: isDestinationViewVisible)
    }
    
    
    func addProgressCircle() {
        
        let circlePath = UIBezierPath(ovalIn: progressView.bounds.insetBy(dx: 5 / 2.0, dy: 5 / 2.0))
        
        progressCircle = CAShapeLayer ()
        progressCircle.path = circlePath.cgPath
        progressCircle.strokeColor = htblack.cgColor
        progressCircle.fillColor = grey.cgColor
        progressCircle.lineWidth = 2.5
        
        progressView.layer.insertSublayer(progressCircle, at: 0)
        
        animateProgress(to: 0)
    }
    
    func addExpandedCard() {
        let bundle = Settings.getBundle()!
        let expandedCard: ExpandedCard = bundle.loadNibNamed("ExpandedCard", owner: self, options: nil)?.first as! ExpandedCard
        self.expandedCard = expandedCard
        self.statusCard.addSubview(expandedCard)
        self.statusCard.sendSubview(toBack: expandedCard)
        expandedCard.frame = CGRect(x: 0, y: 90, width: self.statusCard.frame.width, height: 155)
        self.statusCard.clipsToBounds = true
    }
    
    
    func animateProgress(to : Double) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = currentProgress
        animation.toValue = to
        animation.duration = 0.5
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        progressCircle.add(animation, forKey: "ani")
        self.currentProgress = to
    }
    
    func noPhone() {
        self.phoneButton.isHidden = true
        self.tripIcon.alpha = 1
    }
    
    func shakeDestinationView(){
        self.destinationView.transform = CGAffineTransform(translationX: 20, y: 0)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.destinationView.transform = CGAffineTransform.identity
        }, completion: nil)
        
    }
    
    override func updateViewFocus(isInfoViewCardExpanded: Bool, isDestinationViewVisible: Bool){
        self.mapProvider?.updateViewFocus(isInfoViewCardExpanded: isInfoViewCardExpanded, isDestinationViewVisible: isDestinationViewVisible)
    }
}


extension HTView : HTPlacePickerViewDelegate {
    
    func didCancelPlaceSelection(pickerView: HTPlacePickerView) {
        
    }

    func didSelectPlace(place : HyperTrackPlace, pickerView:HTPlacePickerView){
        pickerView.removeFromSuperview()

        if (self.currentAction != nil){
            HTActionService.sharedInstance.patchExpectedPlaceInAction(actionId: (self.currentAction?.id)!, newExpectedPlaces: place) { (action, error) in
                if let error = error {
                    
                }
                else{
                    self.selectedHypertrackPlace  = place
//                    if(!fromHistory){
//                        Settings.addPlaceToSavedPlaces(place: place)
//                    }
                    self.isDestinationViewEmpty = false
                    var destinationText = ""
                    if(place.name != nil){
                        destinationText = place.name!
                    }
                    if(place.address != nil){
                        destinationText = destinationText + ", " + place.address!
                    }
                    self.destination.text = destinationText
                    self.destinationTitle.text = "Destination"
                }
            }
        }
        
    }
    
}



extension HTView : MapCustomizationDelegate{
    
    func annotationView(_ mapView: MKMapView, annotation: HTMapAnnotation) -> MKAnnotationView?
    {
        
        if(annotation.type == HTConstants.MarkerType.HERO_MARKER){
            return self.customizationDelegate?.heroMarkerViewForActionID?(actionID: (annotation.action?.id)!)
        }
        else if (annotation.type == HTConstants.MarkerType.DESTINATION_MARKER){
            return self.customizationDelegate?.expectedPlaceMarkerViewForActionID?( actionID: (annotation.action?.id)!)
        }
        
        return nil
    }
    
    
    func imageView(_ mapView: MKMapView, annotation: HTMapAnnotation) -> UIImage?{
        
        if(annotation.type == HTConstants.MarkerType.HERO_MARKER){
            return self.customizationDelegate?.heroMarkerImageForActionID?(actionID: (annotation.action?.id)!)
        }
        else if (annotation.type == HTConstants.MarkerType.DESTINATION_MARKER){
            return self.customizationDelegate?.expectedPlaceMarkerImageForActionID?(actionID: (annotation.action?.id)!)
        }
        return nil
    }
    
}


