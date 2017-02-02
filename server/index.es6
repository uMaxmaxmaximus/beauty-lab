//polyfills
import 'babel-polyfill'
import './core/date-timezone'
import './core/date-format'


//time
import config from './config'
Date.setTimezoneOffset(config.timezoneOffset)

import './core/encoder-formats'

//models
import './models/user'

console.log('server starting')



