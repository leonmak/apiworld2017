// Importing express
var express = require('express');

// Creating a Router
var route = express.Router();

route.post('/set', function(req, res) {
    res.json({
        success: true
    });
});

route.post('/reached', function(req, res) {
    try {
        var otp = Math.floor(Math.random() * 10000).toString();

        while (otp.length < 4) {
            otp = '0' + otp;
        }

        Parse.Cloud.httpRequest({
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },

            url: "http://apiworld2017.back4app.io/set",

            body: {
                success: true,
                otp: otp
            }
        }).then(function(httpResponse) {
            console.log(httpResponse.text);
        }, function(httpResponse) {
            console.error('Request failed with response code ' + httpResponse.status);
        });

        res.json({
            success: true,
            otp: otp
        });

    } catch(error) {
        res.json({
            success: false,
            error: error
        });
    }
});

module.exports = route;