// Helper modules that will be used
var path = require('path');
var bodyParser = require('body-parser')

// This imports the Router that uses the template engine
var index = require('./routers/index');

// Sets the template engine as EJS
app.set('view engine', 'ejs');

// This defines that the 'views' folder contains the templates
app.set('views', path.join(__dirname, '/views'));

// These options are necessary to 
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())

// This bind the Router to the / route
app.use('/', index)