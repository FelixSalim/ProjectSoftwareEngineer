extends CanvasModulate

# Stores time passed
var time = 0.5 * PI
var colorTime = 0.08 * PI

# Load Gradient Texture
@export var gradient:GradientTexture1D

# Constants
const DAY_PER_MONTH = 28
const MINUTES_PER_DAY = 1440
const MINUTES_PER_HOUR = 60
const INGAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY

# Signal that time has ticked
signal time_tick(day, hour, minute)

# Signal for force sleep
signal force_sleep(forced)

# Stores last minute
var lastMinute = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
# Every frame add time and adjust color to time cycle
# Only do so if player is not interacting
func _process(delta: float) -> void:
	if not Game.isInteracting:
		time += delta / 120
		#print(time)
		colorTime += delta / 240
		if(colorTime >= PI):
			colorTime = 0.0
		# Calculates value to time
		var value = (cos(colorTime) + 1)/2
		
		# Set color to value
		self.color = gradient.gradient.sample(value)
		
		# Calculate in game time with respect to real time
		recalculate_time()

# Move to beginning of next day
func next_day():
	# Current total game minutes
	var curTime = real_to_ingame_time(time)
	
	# Total day that has passed (starts from 0)
	var day = int(curTime / MINUTES_PER_DAY)
	
	# Remaining minutes for the day
	var currentTotalMinutes = curTime % MINUTES_PER_DAY

	var missingTime
	# If 6 am has passed, move to the next day, else, move to 6 am of current day	
	if currentTotalMinutes / MINUTES_PER_HOUR >= 6:
		missingTime = MINUTES_PER_DAY - currentTotalMinutes + 6 * MINUTES_PER_HOUR - 6
	else:
		missingTime = 6 * MINUTES_PER_HOUR - currentTotalMinutes - 6
	
	# Add the missing time equivalent to real time
	time += ingame_to_real_time(missingTime)
	colorTime = 0.08 * PI
	
	# Recalculate time again
	recalculate_time()

# Convert real time to ingame time
func real_to_ingame_time(inTime):
	return int(inTime / INGAME_TO_REAL_MINUTE_DURATION)

# Convert ingame time to real time
func ingame_to_real_time(inTime):
	return inTime * INGAME_TO_REAL_MINUTE_DURATION

# Recalibrate time every frame
func recalculate_time():
	# Total game minutes
	var totalMinutes = real_to_ingame_time(time)
	
	# Total game days
	var day = int(totalMinutes / MINUTES_PER_DAY)
	
	# Total month that has passed (starts from 0)
	var month = int(day / DAY_PER_MONTH)
	
	# Current day of the month
	var curDay = day % DAY_PER_MONTH
	
	# Total minutes passed for current day
	var currentDayMinutes = totalMinutes % MINUTES_PER_DAY
	
	# Calculate game hour
	var hour = int(currentDayMinutes / MINUTES_PER_HOUR)
	
	# Calculate game minute
	var minute = int(currentDayMinutes % MINUTES_PER_HOUR)
	
	# Emit tick signal if minute change
	if lastMinute != minute:
		lastMinute = minute
		time_tick.emit(curDay, hour, minute)
	
		# if time has reach 2 am, emit force sleep signal
		if hour == 2:
			force_sleep.emit(true)
