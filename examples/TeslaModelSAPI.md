HOST: https://portal.vn.teslamotors.com

# Tesla Model S REST API
This is unofficial documentation of the Tesla Model S REST API used by the iOS and Android apps. It features functionality to monitor and control the Model S remotely. 

# Authentication Flow
These endpoints handle login and session management

## GET /login
Returns the login form. Sets a *_s_portal_session* cookie for the session

### Response 200

#### Headers

	Set-Cookie: _s_portal_session={cookie}; path=/; secure; HttpOnly

#### Body

	{}
	
## POST /login
Performs the login. Takes in an plain text email and password, matching the owner's login from http://teslamotors.com/mytesla. 
Sets a *user_credentials* cookie that expires in 3 months, which is passed along with all future requests to authenticate the user.
302 redirects back to a dummy welcome page. This page is ignored by the smartphone app and can be ignored by your API client.

### Request (application/x-www-form-urlencoded)

	user_session%5Bemail%5D=string&user_session%5Bpassword%5D=string

### Response 302 

#### Headers

	Set-Cookie: _s_portal_session={cookie}; path=/; secure; HttpOnly
	Set-Cookie: user_credentials=x; path=/; expires=Fri, 03-May-2013 03:01:54 GMT; secure; HttpOnly
	Location: https://portal.vn.teslamotors.com/

#### Body

	{}

# Vehicle List
A logged in user can have multiple vehicles under their account. This resource is primarily responsible for listing the vehicles and the basic details about them.

Must have a *_s_portal_session* and *user_credentials* cookie set for all requests.

## GET /vehicles
Retrieve a list of your owned vehicles (includes vehicles not yet shipped!)

### Response 200 (application/json)

	[{
	    "color": null,
	    "display_name": null,
	    "id": 321,
	    "option_codes": "MS01,RENA,TM00,DRLH,PF00,BT85,PBCW,RFPO,WT19,IBMB,IDPB,TR00,SU01,SC01,TP01,AU01,CH00,HP00,PA00,PS00,AD02,X020,X025,X001,X003,X007,X011,X013",
	    "user_id": 123,
	    "vehicle_id": 1234567890,
	    "vin": "5YJSA1CN5CFP01657",
	    "tokens": ["x", "x"],
	    "state": "online"
	}]

# Vehicle Status
These resources are read-only and determine the state of the vehicle's various sub-systems.

Must have a *_s_portal_session* and *user_credentials* cookie set for all requests.

## GET /vehicles/{id}/mobile_enabled
Determines if mobile access to the vehicle is enabled.

### Response 200 (application/json)

	{
	    "reason":"",
	    "result":true
	}

## GET /vehicles/{id}/command/charge_state
Returns the state of charge in the battery.

### Response 200 (application/json)

#### Parameters
+ charging_state = "Complete" ... "Charging", ??
+ charge_to_max_range = false (bool) ... current std/max-range setting
+ max_range_charge_counter = 0 (number)
+ fast_charger_present = false (bool) ... connected to Supercharger?
+ battery_range = 239.02 (number) ... rated miles
+ est_battery_range = 155.79 (number) ... range estimated from recent driving
+ ideal_battery_range = 275.09 (number) ... ideal miles
+ battery_level = 91 (number) ... integer charge percentage
+ battery_current = -0.6 (number) ... current flowing into battery
+ charge_starting_range = null
+ charge_starting_soc = null
+ charger_voltage = 0 (number) ... only has value while charging
+ charger_pilot_current = 40 (number) ... max current allowed by charger & adapter
+ charger_actual_current = 0 (number) ... current actually being drawn
+ charger_power = 0 (number) ... kW (rounded down) of charger
+ time_to_full_charge = 0 (number) ... valid only while charging
+ charge_rate = -1.0 (number) ... float mi/hr charging or -1 if not charging
+ charge_port_door_open = true (bool)

#### Body

	{
	    "charging_state": "Complete",
	    "charge_to_max_range": false,
	    "max_range_charge_counter": 0,
	    "fast_charger_present": false,
	    "battery_range": 239.02,
	    "est_battery_range": 155.79,
	    "ideal_battery_range": 275.09,
	    "battery_level": 91,
	    "battery_current": -0.6,
	    "charge_starting_range": null,
	    "charge_starting_soc": null,
	    "charger_voltage": 0,
	    "charger_pilot_current": 40,
	    "charger_actual_current": 0,
	    "charger_power": 0,
	    "time_to_full_charge": null,
	    "charge_rate": -1.0,
	    "charge_port_door_open": true
	}

## GET /vehicles/{id}/command/climate_state
Returns the current temperature and climate control state.

### Response 200 (application/json)

#### Parameters
+ inside_temp = 17.0 (number) ... degC inside car
+ outside_temp = 9.5 (number) ... degC outside car or null
+ driver_temp_setting = 22.6 (number) ... degC of driver temperature setpoint
+ passenger_temp_setting = 22.6 (number) ... degC of passenger temperature setpoint
+ is_auto_conditioning_on = false (bool) ... apparently even if on
+ is_front_defroster_on = (number) ... null or boolean as integer?
+ is_rear_defroster_on = (bool)
+ fan_status = 0 ... fan speed 0-6 or null

#### Body

	{
	    "inside_temp": 17.0,
	    "outside_temp": 9.5,
	    "driver_temp_setting": 22.6,
	    "passenger_temp_setting": 22.6,
	    "is_auto_conditioning_on": false,
	    "is_front_defroster_on": null,
	    "is_rear_defroster_on": false,
	    "fan_status": 0
	}


## GET /vehicles/{id}/command/drive_state
Returns the driving and position state of the vehicle.

### Response 200 (application/json)

#### Parameters
+ shift_state = null
+ speed = null
+ latitude = 33.794839 (number) ... degrees N of equator
+ longitude = 84.401593 (number) ... degrees W of the prime meridian
+ heading = 4 (number) ... integer compass heading, 0-359
+ gps_as_of = 1359863204 (number) ... Unix timestamp of GPS fix

#### Body

	{
	    "shift_state": null,
	    "speed": null,
	    "latitude": 33.794839,
	    "longitude": -84.401593,
	    "heading": 4,
	    "gps_as_of": 1359863204
	}

## GET /vehicles/{id}/command/gui_settings
Returns various information about the GUI settings of the car, such as unit format and range display.

### Response 200 (application/json)
	{
	    "gui_distance_units": "mi/hr",
	    "gui_temperature_units": "F",
	    "gui_charge_rate_units": "mi/hr",
	    "gui_24_hour_time": false,
	    "gui_range_display": "Rated"
	}


## GET /vehicles/{id}/command/vehicle_state
Returns the vehicle's physical state, such as which doors are open.

### Response 200 (application/json)

#### Parameters
+ df = false (bool) ... driver's side front door open
+ dr = false (bool) ... driver's side rear door open
+ pf = false (bool) ... passenger's side front door open
+ pr = false (bool) ... passenger's side rear door open
+ ft = false (bool) ... front trunk is open
+ rt = false (bool) ... rear trunk is open
+ car_verson = "1.19.42" (string) ... car firmware version
+ locked = true (bool) ... car is locked
+ sun_roof_installed = false (bool) ... panoramic roof is installed
+ sun_roof_state = "unknown" (string)
+ sun_roof_percent_open = 0 (number) ... null if not installed
+ dark_rims = false (bool) ... gray rims installed
+ wheel_type = "Base19" (string) ... wheel type installed
+ has_spoiler = false (bool) ... spoiler is installed
+ roof_color = "Colored" ... "None" for panoramic roof

#### Body

	{
	    "df": false,                  // driver's side front door open
	    "dr": false,                  // driver's side rear door open
	    "pf": false,                  // passenger's side front door open
	    "pr": false,                  // passenger's side rear door open
	    "ft": false,                  // front trunk is open
	    "rt": false,                  // rear trunk is open
	    "car_verson": "1.19.42",      // car firmware version
	    "locked": true,               // car is locked
	    "sun_roof_installed": false,  // panoramic roof is installed
	    "sun_roof_state": "unknown",
	    "sun_roof_percent_open": 0,   // null if not installed
	    "dark_rims": false,           // gray rims installed
	    "wheel_type": "Base19",       // wheel type installed
	    "has_spoiler": false,         // spoiler is installed
	    "roof_color": "Colored",      // "None" for panoramic roof
	    "perf_config": "Base"
	}

# Vehicle Commands
 
	
## GET /vehicles/{id}/command/charge_port_door_open
Open the charge port

### Response 200 (application/json)

	{
	  "result": false,
	  "reason": "failure reason"
	}

## GET /vehicles/{id}/command/charge_standard
Set the charge mode to standard.

### Response 200 (application/json)

	{
	  "result": false,
	  "reason": "failure reason"
	}

## GET /vehicles/{id}/command/charge_max_range
Set the charge mode to max-range.

### Response 200 (application/json)
	{
	  "result": false,
	  "reason": "failure reason"
	}

## GET /vehicles/{id}/command/charge_start 
Start charging

### Response 200 (application/json)

	{
	  "result": false,
	  "reason": "failure reason"  // "already started" if a charge is in progress
	}

## GET /vehicles/{id}/command/charge_stop
Stop charging

### Response 200 (application/json)

	{
	  "result": false,
	  "reason": "failure reason"   // "not_charging" if a charge was not in progress
	}

## GET /vehicles/{id}/command/flash_lights
Flash the lights once

### Response 200 (application/json)
	
	{
	  "result": false,
	  "reason": "failure reason"
	}

## GET /vehicles/{id}/command/honk_horn
Honk horn once

### Response 200 (application/json)

	{
	  "result": false,
	  "reason": "failure reason"
	}

## GET /vehicles/{id}/command/door_unlock
Unlock doors

### Response 200 (application/json)

	{
	  "result": false,
	  "reason": "failure reason"
	}

## GET /vehicles/{id}/command/door_lock
Lock doors

### Response 200 (application/json)

	{
	  "result": false,
	  "reason": "failure reason"
	}

## GET /vehicles/{id}/command/set_temps?driver_temp={driver_degC}&passenger_temp={pass_degC}
Set the temperature setpoints

### Response 200 (application/json)

	{
	  "result": false,
	  "reason": "failure reason"
	}

## GET /vehicles/{id}/command/auto_conditioning_start
Start HVAC

### Response 200 (application/json)

	{
	  "result": false,
	  "reason": "failure reason"
	}

## GET /vehicles/{id}/command/auto_conditioning_stop
Stop HVAC

### Response 200 (application/json)

	{
	  "result": false,
	  "reason": "failure reason"
	}

## GET /vehicles/{id}/command/sun_roof_control?state={state}
Panoramic roof control

### Parameters
+ state (string) ... State may be "open", "close", "comfort", or "vent". 

### Response 200 (application/json)
	{
	  "result": false,
	  "reason": "failure reason"
	}
