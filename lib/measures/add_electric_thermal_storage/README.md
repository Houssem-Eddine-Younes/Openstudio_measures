

###### (Automatically generated documentation)

# Add Central Electric Thermal Storage V2

## Description
This measures adds a central Electric Thermal Storage (ETS) to the current building model

## Modeler Description
Refer to measure documentation for input description and use cases

## Measure Type
ModelMeasure

## Taxonomy


## Arguments


### Enter device name and number 
This is the unique identifier of the device. Use distinct names.
**Name:** atc_name,
**Type:** String,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Select Loop:
Error: No loops were found
**Name:** selected_loop,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

**Choice Display Names** []


### Select Boiler:
Error: No boilers were found
**Name:** selected_boiler,
**Type:** Choice,
**Units:** ,
**Required:** false,
**Model Dependent:** false

**Choice Display Names** []


### Location of storage device:
This selects where the storage device is mounted
**Name:** storage_placement,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

**Choice Display Names** ["Upstream", "Downstream", "Parallel"]


### Select Charging Schedule:
Error: No schedules were found elsewhere in the model
**Name:** selected_charging_schedule,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

**Choice Display Names** []


### Select Discharging Schedule:
Error: No schedules were found elsewhere in the model
**Name:** selected_discharging_schedule,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

**Choice Display Names** []


### Select Peak Power Schedule:
Error: No schedules were found elsewhere in the model
**Name:** selected_peakpower_schedule,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

**Choice Display Names** []


### Enter the Initial Brick Temperature [°C]:

**Name:** initial_temperature,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Enter the Maximum Brick Target Temperature [°C]:

**Name:** storage_Temperature_High_Limit,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Enter the Minimum Outdoor Temperature [°C]:

**Name:** minimum_Outdoor_Temperature,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Enter the Minimum Brick Target Temperature [°C]:

**Name:** storage_Temperature_Low_Limit,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Enter the Maximum Outdoor Temperature [°C]:

**Name:** maximum_Outdoor_Temperature,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Enter device Mass Flow Rate [kg/s]:

**Name:** mass_Flow_Rate,
**Type:** Double,
**Units:** ,
**Required:** true,
**Model Dependent:** false


### Select ambient zone:
Error: No zones were found
**Name:** selected_zone,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

**Choice Display Names** []


### Select Reporting Frequency for New Output Variables
This will not change reporting frequency for existing output variables in the model.
**Name:** report_freq,
**Type:** Choice,
**Units:** ,
**Required:** false,
**Model Dependent:** false

**Choice Display Names** ["Detailed", "Timestep", "Hourly", "Daily", "Monthly", "RunPeriod"]


### Level of output reporting related to the EMS internal variables that are available.

**Name:** internal_variable_availability_dictionary_reporting,
**Type:** Choice,
**Units:** ,
**Required:** true,
**Model Dependent:** false

**Choice Display Names** ["None", "NotByUniqueKeyNames", "Verbose"]






