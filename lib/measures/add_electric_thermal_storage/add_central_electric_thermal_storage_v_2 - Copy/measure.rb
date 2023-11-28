class AddCentralElectricThermalStorageV2 < OpenStudio::Measure::ModelMeasure

  # define the name that a user will see
  def name
    return "Add Central Electric Thermal Storage V2"
  end
  # human readable description
  def description
    return "This measures adds a central Electric Thermal Storage (ETS) to the current building model"
  end

  # human readable description of modeling approach
  def modeler_description
    return "Code developed by M. Houssem Eddine Younes, M.Sc. Supervised by Mme. Katherine D'Avignon, Ph.D  & M. François Laurencelle, Ph.D. Funded by Mitacs Inc and Hydro-Québec."
  end

  # define the arguments that the user will input
  def arguments(model)
    args = []

	# Enter device name / number
	atc_name = OpenStudio::Measure::OSArgument.makeStringArgument('atc_name', true)
	atc_name.setDisplayName('Enter device name and number ')
	atc_name.setDescription('This is the unique identifier of the device. Use distinct names.')
  atc_name.setDefaultValue('ETS1')
  args << atc_name


	# Select Which loop to add ATC to
	plant_loops = model.getPlantLoops
  loop_choices = OpenStudio::StringVector.new
  plant_loops.each do |loop|
    if loop.sizingPlant.loopType.to_s == 'Heating'
        loop_choices << loop.name.to_s
    end
  end

	# Make choice argument for loop selection
  selected_loop = OpenStudio::Measure::OSArgument.makeChoiceArgument('selected_loop', loop_choices, true)
  selected_loop.setDisplayName('Select Loop:')
  selected_loop.setDescription('This is the Heating loop on which ETS will be added.')
  if !plant_loops.empty?
  	selected_loop.setDefaultValue(loop_choices[0])
  else
  	selected_loop.setDescription('Error: No loops were found')
  end
  args << selected_loop


	#Look for central heating devices such as boilers
	boilers = model.getBoilerHotWaters
	boiler_choices = OpenStudio::StringVector.new
	boilers.each do |boiler|
		boiler_choices << boiler.name.to_s
	end
  if !boilers.empty?
		boolarg = true
	else
		boolarg = false
	end


	# Make choice argument for boilers to operate alongside storage device
	selected_boiler = OpenStudio::Measure::OSArgument.makeChoiceArgument('selected_boiler', boiler_choices, boolarg)
  selected_boiler.setDisplayName('Select Boiler:')
	selected_boiler.setDescription('This equipment will operate alongside the storage device.')
	if !boilers.empty?
		selected_boiler.setDefaultValue(boiler_choices[0])
	else
		selected_boiler.setDescription('Error: No boilers were found')
	end
    args << selected_boiler


	# Select placement of the storage device
	storage_placement = OpenStudio::Measure::OSArgument.makeChoiceArgument('storage_placement', ['Upstream', 'Downstream','Parallel'], true)
  storage_placement.setDisplayName('Location of storage device:')
	storage_placement.setDescription('This selects where the storage device is mounted')
  storage_placement.setDefaultValue('Parallel')
  args << storage_placement


	# find all schedules in model
	schedules = model.getSchedules
	schedule_choices = OpenStudio::StringVector.new
	schedules.each do |schedule|
		schedule_choices << schedule.name.to_s
	end

	# select charging authorization schedule
	selected_charging_schedule = OpenStudio::Measure::OSArgument.makeChoiceArgument('selected_charging_schedule', schedule_choices, true)
	selected_charging_schedule.setDisplayName('Select Charging Schedule:')
	selected_charging_schedule.setDescription('This schedule should contain electric charging authorizations values.')
	if !schedules.empty?
		selected_charging_schedule.setDefaultValue(schedule_choices[0])
	else
		selected_charging_schedule.setDescription('Error: No schedules were found elsewhere in the model')
	end
	args << selected_charging_schedule

	# select discharge authorizaztion schedule
	selected_discharging_schedule = OpenStudio::Measure::OSArgument.makeChoiceArgument('selected_discharging_schedule', schedule_choices, true)
	selected_discharging_schedule.setDisplayName('Select Discharging Schedule:')
	selected_discharging_schedule.setDescription('This schedule should contain heat discharging authorization values values.')
	if !schedules.empty?
		selected_discharging_schedule.setDefaultValue(schedule_choices[0])
	else
		selected_discharging_schedule.setDescription('Error: No schedules were found elsewhere in the model')
	end
	args << selected_discharging_schedule


	# select building maximum demand schedule
	selected_peakpower_schedule = OpenStudio::Measure::OSArgument.makeChoiceArgument('selected_peakpower_schedule', schedule_choices, true)
	selected_peakpower_schedule.setDisplayName('Select Peak Power Schedule:')
	selected_peakpower_schedule.setDescription('Scheduled peak demand limits [Watts]')
	if !schedules.empty?
		selected_peakpower_schedule.setDefaultValue(schedule_choices[0])
	else
		selected_peakpower_schedule.setDescription('Error: No schedules were found elsewhere in the model')
	end
	args << selected_peakpower_schedule

  # Make double argument for Initial Brick Temperature
  initial_temperature = OpenStudio::Measure::OSArgument.makeDoubleArgument('initial_temperature', true)
  initial_temperature.setDisplayName('Enter the Initial Brick Temperature [°C]:')
  initial_temperature.setDefaultValue(760)
  args << initial_temperature

  # Make double argument for Maximum brick core target temperature
  storage_Temperature_High_Limit = OpenStudio::Measure::OSArgument.makeDoubleArgument('storage_Temperature_High_Limit', true)
  storage_Temperature_High_Limit.setDisplayName('Enter the Maximum Brick Target Temperature [°C]:')
  storage_Temperature_High_Limit.setDefaultValue(760)
  args << storage_Temperature_High_Limit

  # Make double argument for Minimum  Outdoor air temperature
  minimum_Outdoor_Temperature = OpenStudio::Measure::OSArgument.makeDoubleArgument('minimum_Outdoor_Temperature', true)
  minimum_Outdoor_Temperature.setDisplayName('Enter the Minimum Outdoor Temperature [°C]:')
  minimum_Outdoor_Temperature.setDefaultValue(-15)
  args << minimum_Outdoor_Temperature

  # Make double argument for Minimum brick core target temperature
  storage_Temperature_Low_Limit = OpenStudio::Measure::OSArgument.makeDoubleArgument('storage_Temperature_Low_Limit', true)
  storage_Temperature_Low_Limit.setDisplayName('Enter the Minimum Brick Target Temperature [°C]:')
  storage_Temperature_Low_Limit.setDefaultValue(100)
  args << storage_Temperature_Low_Limit

  # Make double argument for Maximum outdoor air temperature
  maximum_Outdoor_Temperature = OpenStudio::Measure::OSArgument.makeDoubleArgument('maximum_Outdoor_Temperature', true)
  maximum_Outdoor_Temperature.setDisplayName('Enter the Maximum Outdoor Temperature [°C]:')
  maximum_Outdoor_Temperature.setDefaultValue(15)
  args << maximum_Outdoor_Temperature

  # Make double argument for Maximum mass flow rate
  mass_Flow_Rate = OpenStudio::Measure::OSArgument.makeDoubleArgument('mass_Flow_Rate', true)
  mass_Flow_Rate.setDisplayName('Enter device Mass Flow Rate [kg/s]:')
  mass_Flow_Rate.setDefaultValue(1.86)
  args << mass_Flow_Rate

	#look for zones to add storage device to. (For heat loss calculations)
	zones = model.getThermalZones
  zone_choices = OpenStudio::StringVector.new
  zones.each do |zone|
  zone_choices << zone.name.to_s
  end

	# make choice argument for zone name selection
  selected_zone = OpenStudio::Measure::OSArgument.makeChoiceArgument('selected_zone', zone_choices, true)
  selected_zone.setDisplayName('Select ambient zone:')
  selected_zone.setDescription('this is the thermal zone where the equipment will be installed.')
  if !zones.empty?
		selected_zone.setDefaultValue(zone_choices[0])
	else
		selected_zone.setDescription('Error: No zones were found')
	end
  args << selected_zone

  # Make choice argument for output variable reporting frequency
  report_choices = ['Detailed', 'Timestep', 'Hourly', 'Daily', 'Monthly', 'RunPeriod']
  report_freq = OpenStudio::Measure::OSArgument.makeChoiceArgument('report_freq', report_choices, false)
  report_freq.setDisplayName('Select Reporting Frequency for New Output Variables')
  report_freq.setDescription('This will not change reporting frequency for existing output variables in the model.')
  report_freq.setDefaultValue('Timestep')
  args << report_freq

	#  make a choice argument for setting EMS InternalVariableAvailabilityDictionaryReporting value
  int_var_avail_dict_rep_chs = OpenStudio::StringVector.new
  int_var_avail_dict_rep_chs << 'None'
  int_var_avail_dict_rep_chs << 'NotByUniqueKeyNames'
  int_var_avail_dict_rep_chs << 'Verbose'
  # the 'Verbose' option is useful only for debugging and creates very large *.EDD file. Leave default input unless debugging code.
  internal_variable_availability_dictionary_reporting = OpenStudio::Measure::OSArgument.makeChoiceArgument('internal_variable_availability_dictionary_reporting', int_var_avail_dict_rep_chs, true)
  internal_variable_availability_dictionary_reporting.setDisplayName('Level of output reporting related to the EMS internal variables that are available.')
  internal_variable_availability_dictionary_reporting.setDefaultValue('None')
  args << internal_variable_availability_dictionary_reporting
    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)

	# use the built-in error checking
    unless runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

	# The following code fixes the issue of EMS objects being orphaned after deletion of a PCUD object previously added by this measure.
	pcud_initProgram_found = false
	model.getObjectsByName("PCUD_InitProgram",false).each do |object|
	pcud_initProgram_found = true
	object.remove
	end

	pcud_simProgram_found = false
	model.getObjectsByName("PCUD_SimProgram",false).each do |object|
	pcud_simProgram_found = true
	object.remove
	end

	pcud_initCallingManager_found = false
	model.getObjectsByName("PCUD_InitProgramCallingManager",false).each do |object|
	pcud_initCallingManager_found = true
	object.remove
	end

	pcud_simCallingManager_found = false
	model.getObjectsByName("PCUD_SimProgramCallingManager",false).each do |object|
	pcud_simCallingManager_found = true
	object.remove
	end


	# 1. find all PCUD objects
	pcudobjects = model.getObjectsByType("OS:PlantComponent:UserDefined".to_IddObjectType)
	# 2. find PCUD objects associated to ETS
	etsobjectnames = []
	pcudobjects.each do |object|
	if object.name.to_s.include?("SimETS")
		etsobjectnames << object.name.to_s
	end
	end
	# 3. print the ETS devices name list
	# etsobjectnames.each do |name|
	# 	runner.registerInfo("device #{name} is in the model")
	# end
	# 4. print the size of the ETS device list
	counter = etsobjectnames.size
	runner.registerInfo("the model currently has #{counter} ETS devices: #{etsobjectnames.inspect}")

	# Find and remove all orphaned objects : EMS:GlobalVariables, EMS:sensors, EMS:actuators, EMS:InternalVariables, EMS:outputvariable, EMS:MeteredOutputVariables EMS:TrendVariables
	ems_globalvariable = model.getObjectsByType("OS:EnergyManagementSystem:GlobalVariable".to_IddObjectType)
	ems_sensors = model.getObjectsByType("OS:EnergyManagementSystem:Sensor".to_IddObjectType)
	ems_actuators = model.getObjectsByType("OS:EnergyManagementSystem:Actuator".to_IddObjectType)
	ems_internalvariables = model.getObjectsByType("OS:EnergyManagementSystem:InternalVariable".to_IddObjectType)
	ems_outputvariables = model.getObjectsByType("OS:EnergyManagementSystem:OutputVariable".to_IddObjectType)
	ems_meteredoutputvariables = model.getObjectsByType("OS:EnergyManagementSystem:MeteredOutputVariable".to_IddObjectType)
	ems_trendvariables = model.getObjectsByType("OS:EnergyManagementSystem:TrendVariable".to_IddObjectType)
	# find all ems variables
	list_of_all_ems_variables = ems_globalvariable + ems_sensors + ems_actuators + ems_internalvariables + ems_outputvariables + ems_meteredoutputvariables + ems_trendvariables
  list_of_ets_ems_variables = []
  list_of_all_ems_variables.each do |var|
		parts = var.name.to_s.split(/_/, 3)
		if parts[0] == "SimETS"
			list_of_ets_ems_variables.push(var)
		end
	end

	if !etsobjectnames.empty?
		list_of_ets_ems_variables.each do |var|
			parts = var.name.to_s.split(/_/, 3)
			etsobjectnames.each do |name|
				if name == "#{parts[0]}_#{parts[1]}"
					runner.registerInfo("The EMS variable #{var.name} is associated with an ETS object existant in the model")
				else
					runner.registerInfo("The EMS variable #{var.name} is not associated with an ETS object existant in the model. It is an orphaned object and will be deleted")
					var.remove
				end
			end
		end
	else
		list_of_ets_ems_variables.each do |var|
			runner.registerInfo("There are no ETS devices in the model.The EMS variable #{var.name} will be deleted since it is not associated with an ETS object existant in the model.")
			var.remove
		end
	end

    # Assign user arguments to variables
	atc_name = runner.getStringArgumentValue('atc_name', user_arguments)
	selected_loop = runner.getStringArgumentValue('selected_loop',user_arguments)
	boilers = model.getBoilerHotWaters
	if !boilers.empty?
		selected_boiler = runner.getStringArgumentValue('selected_boiler', user_arguments)
	else
		selected_boiler = runner.getOptionalStringArgumentValue('selected_boiler', user_arguments)
	end

	storage_placement = runner.getStringArgumentValue('storage_placement',user_arguments)
	selected_charging_schedule = runner.getStringArgumentValue('selected_charging_schedule', user_arguments)
	selected_discharging_schedule = runner.getStringArgumentValue('selected_discharging_schedule', user_arguments)
	selected_peakpower_schedule = runner.getStringArgumentValue('selected_peakpower_schedule', user_arguments)
	initial_temperature = runner.getDoubleArgumentValue('initial_temperature', user_arguments)
	storage_Temperature_High_Limit = runner.getDoubleArgumentValue('storage_Temperature_High_Limit', user_arguments)
	minimum_Outdoor_Temperature = runner.getDoubleArgumentValue('minimum_Outdoor_Temperature', user_arguments)
	storage_Temperature_Low_Limit = runner.getDoubleArgumentValue('storage_Temperature_Low_Limit', user_arguments)
	maximum_Outdoor_Temperature = runner.getDoubleArgumentValue('maximum_Outdoor_Temperature', user_arguments)
	mass_Flow_Rate = runner.getDoubleArgumentValue('mass_Flow_Rate', user_arguments)
	selected_zone = runner.getStringArgumentValue('selected_zone',user_arguments)
	report_freq = runner.getStringArgumentValue('report_freq', user_arguments)
  internal_variable_availability_dictionary_reporting = runner.getStringArgumentValue('internal_variable_availability_dictionary_reporting', user_arguments)


	# Create PCUD object as a proxy for an Electric Thermal Storage (ETS) device
	my_atc = OpenStudio::Model::PlantComponentUserDefined.new(model)
  # set name (Unique identifier (UID)) for ETS device. PCUD objects that simulate an ETS device are prefixed with the keyword "SimETS" in order to differentiate them from other PCUD objects.
  my_atc.setName("SimETS_#{atc_name}")
  runner.registerInfo("An ETS device named #{atc_name} was added to the model")
  # clear PCUD default programs
  my_atc.resetPlantInitializationProgram()
  my_atc.resetPlantSimulationProgram()

	# find hot water loops in the model
	user_selected_loop = model.getPlantLoopByName(selected_loop).get
	# Set Plant load default distribution mode ( Sequential, UniformLoad, Optimal etc..)
	#user_selected_loop.setLoadDistributionScheme("Sequential")
	user_selected_loop.setLoadDistributionScheme("UniformLoad")
	# set ETS loading mode
	my_atc.setPlantLoadingMode('MeetsLoadWithNominalCapacityHiOutLimit')
	# Set ETS flow request mode
	my_atc.setPlantLoopFlowRequestMode('NeedsFlowIfLoopOn')

  #Look for central heating devices such as boilers
  boilers = model.getBoilerHotWaters
  # add component to the user-selected loop
  if !boilers.empty?
    my_boiler = model.getBoilerHotWaterByName(selected_boiler).get
  end

  # if there is a boiler in the model, add the ETS at the specified configuration (Parallel,Upstream,Downstream) otherwise just create an additional branch for the ETS

  if !boilers.empty?
    if storage_placement == 'Parallel'
      user_selected_loop.addSupplyBranchForComponent(my_atc)
    elsif storage_placement == 'Upstream'
      my_atc.addToNode(my_boiler.inletModelObject.get.to_Node.get)
    elsif storage_placement == 'Downstream'
      my_atc.addToNode(my_boiler.outletModelObject.get.to_Node.get)
    end
  else
    user_selected_loop.addSupplyBranchForComponent(my_atc)
  end

  # add constant speed pump for the ETS
	hw_pump = OpenStudio::Model::PumpConstantSpeed.new(model)
	hw_pump.setName("#{my_atc.name} Pump")
	hw_pump.setRatedFlowRate(mass_Flow_Rate/1000)
  hw_pump.setRatedPumpHead(179352)
  hw_pump.setMotorEfficiency(0.9)
  hw_pump.setPumpControlType('Intermittent')
  hw_pump.addToNode(my_atc.inletModelObject.get.to_Node.get)

  # add component to user-defined ambient zone
  my_zone = model.getThermalZoneByName(selected_zone).get
  my_atc.setAmbientZone(my_zone)

  # Get user selected schedules (charge, discharge, peak demand)
	user_selected_charging_schedule = model.getScheduleByName(selected_charging_schedule).get
	user_selected_discharging_schedule = model.getScheduleByName(selected_discharging_schedule).get
	user_selected_peakpower_schedule = model.getScheduleByName(selected_peakpower_schedule).get

  #-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
                                                                                                          # Get PCUD actuators handles
 #-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

  # minimum mass flow rate actuator
  mdot_min_act = my_atc.minimumMassFlowRateActuator.get
  mdot_min_act.setName("#{my_atc.name}_m_dot_min")
	mdot_min_act.setActuatedComponent(my_atc)

  # maximum mass flow rate actuator
	mdot_max_act = my_atc.maximumMassFlowRateActuator.get
	mdot_max_act.setName("#{my_atc.name}_m_dot_max")
	mdot_max_act.setActuatedComponent(my_atc)

  # mass flow rate actuator
  mdot_req_act = my_atc.massFlowRateActuator.get
  mdot_req_act.setName("#{my_atc.name}_m_dot_ATC")
  mdot_req_act.setActuatedComponent(my_atc)

  # design flow rate actuator
	vdot_des_act = my_atc.designVolumeFlowRateActuator.get
	vdot_des_act.setName("#{my_atc.name}_Vdot_Des_Act")
	vdot_des_act.setActuatedComponent(my_atc)

  # minimum loading capacity actuator
  cap_min_act = my_atc.minimumLoadingCapacityActuator.get
	cap_min_act.setName("#{my_atc.name}_Cap_Min_Act")
	cap_min_act.setActuatedComponent(my_atc)

  # maximum loading capacity actuator
  cap_max_act = my_atc.maximumLoadingCapacityActuator.get
  cap_max_act.setName("#{my_atc.name}_Cap_Max_Act")
  cap_max_act.setActuatedComponent(my_atc)

  # optimal loading capacity actuator
  cap_opt_act = my_atc.optimalLoadingCapacityActuator.get
  cap_opt_act.setName("#{my_atc.name}_Cap_Opt_Act")
	cap_opt_act.setActuatedComponent(my_atc)

  # outlet temperature actuator
  tout_act = my_atc.outletTemperatureActuator.get
	tout_act.setName("#{my_atc.name}_tg_out")
	tout_act.setActuatedComponent(my_atc)

  # high outlet temperature limit actuator
  tout_max_act = OpenStudio::Model::EnergyManagementSystemActuator.new(my_atc, "Plant Connection 1", "High Outlet Temperature Limit")
  tout_max_act.setName("#{my_atc.name}_Tout_Max_Act")

  # sensible heat loss
  q_sensible_heat_loss_act = OpenStudio::Model::EnergyManagementSystemActuator.new(my_atc, "Component Zone Internal Gain", "Sensible Heat Gain Rate")
  q_sensible_heat_loss_act.setName("#{my_atc.name}_heatloss")

  #-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
	                                                                               # Get internal variables with EMS
  #-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

	 # inlet temperature internal variable
  tin_int_var = OpenStudio::Model::EnergyManagementSystemInternalVariable.new(model, 'Inlet Temperature for Plant Connection 1')
	tin_int_var.setName("#{my_atc.name}_tg_in")
  tin_int_var.setInternalDataIndexKeyName("#{my_atc.name}")
	tin_int_var.setInternalDataType('Inlet Temperature for Plant Connection 1')

  # inlet mass flow rate internal variable
  mdot_int_var = OpenStudio::Model::EnergyManagementSystemInternalVariable.new(model, 'Inlet Mass Flow Rate for Plant Connection 1')
	mdot_int_var.setName("#{my_atc.name}_m_dot_glycol")
  mdot_int_var.setInternalDataIndexKeyName("#{my_atc.name}")
	mdot_int_var.setInternalDataType('Inlet Mass Flow Rate for Plant Connection 1')

	# inlet specific heat internal variable
  cp_int_var = OpenStudio::Model::EnergyManagementSystemInternalVariable.new(model, 'Inlet Specific Heat for Plant Connection 1')
	cp_int_var.setName("#{my_atc.name}_Cp_Int_Var")
  cp_int_var.setInternalDataIndexKeyName("#{my_atc.name}")
	cp_int_var.setInternalDataType('Inlet Specific Heat for Plant Connection 1')

  # inlet density internal variable
  rho_int_var = OpenStudio::Model::EnergyManagementSystemInternalVariable.new(model, 'Inlet Density for Plant Connection 1')
  rho_int_var.setName("#{my_atc.name}_rho_Int_Var")
  rho_int_var.setInternalDataIndexKeyName("#{my_atc.name}")
	rho_int_var.setInternalDataType('Inlet Density for Plant Connection 1')

  # load request internal variable
  load_int_var = OpenStudio::Model::EnergyManagementSystemInternalVariable.new(model, 'Load Request for Plant Connection 1')
  load_int_var.setName("#{my_atc.name}_load_int_var")
  load_int_var.setInternalDataIndexKeyName("#{my_atc.name}")
	load_int_var.setInternalDataType('Load Request for Plant Connection 1')

	# Plant Design Volume Flow Rate
  hw_plant_vdot_des = OpenStudio::Model::EnergyManagementSystemInternalVariable.new(model, 'Plant Design Volume Flow Rate')
  hw_plant_vdot_des.setName("#{my_atc.name}_plant_design_flow_rate")
  hw_plant_vdot_des.setInternalDataIndexKeyName(user_selected_loop.handle.to_s)
  #-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
	                                                                                # Get sensor values with EMS
  #-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
	# Ambient temperature of selected zone
	amb_zone_temp_sen = OpenStudio::Model::EnergyManagementSystemSensor.new(model, 'Zone Air Temperature')
	amb_zone_temp_sen.setName("#{my_atc.name}_t_amb")
  amb_zone_temp_sen.setKeyName(selected_zone)

	# Outdoor air drybulb temperature
  oa_dbt_sen = OpenStudio::Model::EnergyManagementSystemSensor.new(model, 'Site Outdoor Air Drybulb Temperature')
	oa_dbt_sen.setName("#{my_atc.name}_t_ext")
  oa_dbt_sen.setKeyName('Environment')

	# Building power sensor (Electric consumption other than ETS)
  elec_dmd_sen = OpenStudio::Model::EnergyManagementSystemSensor.new(model, 'Facility Total Building Electricity Demand Rate')
	elec_dmd_sen.setName("#{my_atc.name}_p_bat")
  elec_dmd_sen.setKeyName('Whole Building')

	# Plant supply side heating demand rate
	heat_dmd_sen = OpenStudio::Model::EnergyManagementSystemSensor.new(model, 'Plant Supply Side Heating Demand Rate')
	heat_dmd_sen.setName("#{my_atc.name}_q_load")
  heat_dmd_sen.setKeyName("#{selected_loop}")

	# charging schedule value sensor
	aut_char_sen = OpenStudio::Model::EnergyManagementSystemSensor.new(model, 'Schedule Value')
  aut_char_sen.setName("#{my_atc.name}_aut_char")
  aut_char_sen.setKeyName("#{user_selected_charging_schedule.name}")

	# discharging schedule value sensor
	aut_dischar_sen = OpenStudio::Model::EnergyManagementSystemSensor.new(model, 'Schedule Value')
  aut_dischar_sen.setName("#{my_atc.name}_aut_dischar")
  aut_dischar_sen.setKeyName("#{user_selected_discharging_schedule.name}")

	# maximum building power schedule value sensor
	p_max_sen = OpenStudio::Model::EnergyManagementSystemSensor.new(model, 'Schedule Value')
  p_max_sen.setName("#{my_atc.name}_p_max")
  p_max_sen.setKeyName("#{user_selected_peakpower_schedule.name}")

  #-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
	                                                                                                   # create global variables
  #-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

	average_brick_temp = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_AverageBrickTemp")
	brick_init_temp = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_BrickInitTemp")
	brick_temp_trend = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_BrickTempTrend")
	brick_target_core_temp = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_BrickTargetCoreTemp")
	minimum_brick_temp = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_MinimumBrickTemp")
	maximum_brick_temp = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_MaximumBrickTemp")
	minimum_outdoor_temp = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_MinimumOutdoorTemp")
	maximum_outdoor_temp = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_MaximumOutdoorTemp")
	brick_setpoint_error = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_BrickSetpointError")
	plant_load_trend = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_PlantLoadTrend")
	brick_core_mass = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_BrickCoreMass")
	brick_specific_heat = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_BrickSpecificheat")
	brick_heat_loss_coeff = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_BrickHeatLossCoeff")
	atc_nameplate_power = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_AtcNameplatePower")
	maximum_building_power = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_MaximumBuildingPower")
	available_charging_power = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_AvailableChargingPower")
	building_power_dmd = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_BuildingPowerDmd")
	atc_charging_auth = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_AtcChargingAuth")
	atc_discharging_auth = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_AtcDischargingAuth")
	cont_prop_sig_init = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_PropContSigInit")
	cont_prop_cont_sig_fin = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_PropContSigFin")
	cont_output_init = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_ContOutputInit")
	cont_output_fin = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_ContOutputFin")
	cont_prop_gain = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_ContPropGain")
	cont_prop_offset = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_ContPropOffset")
	storage_heating_pwr = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_StorageHeatingPwr")
	storage_heating_ener = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_StorageHeatingEner")
	storage_electric_pwr = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model,  "#{my_atc.name}_StorageElectricPwr")
	storage_electric_ener = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_StorageElectricEner")
	storage_loss_pwr= OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_StorageLossPwr")
	storage_loss_ener= OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_StorageLossEner")
	heating_power_dmd = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_HeatingPowerDmd")
	heating_energy_dmd = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_HeatingEnergyDmd")
	max_brick_heating_capacity = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_MaxBrickHeatingCapacity")
	htf_density = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_Rho")
	htf_specific_heat = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_Cp")
	load_req_ets = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_RequestedLoad")
	maximum_loading_cap = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_MaximumLoadingCapacityCapValue")
	systimestep = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_SystemTimeStep")
	prevtimestependtime = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_PreviousTimeStepEndTime")
	prevtimestepbegintime = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_PreviousTimeStepBeginTime")
	max_cap_actuator_var = OpenStudio::Model::EnergyManagementSystemGlobalVariable.new(model, "#{my_atc.name}_MaximumLoadingCapacity")

  #-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
	                                                                                                  # create trend variables
  #-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

	# Create new EnergyManagementSystem:TrendVariable object to hold the  facility electric demand history
	elec_demand_trend = OpenStudio::Model::EnergyManagementSystemTrendVariable.new(model, elec_dmd_sen)
  elec_demand_trend.setName("#{my_atc.name}_pbat_trend")
  elec_demand_trend.setNumberOfTimestepsToBeLogged(144)

	# Create new EnergyManagementSystem:TrendVariable object  to hold the brick core temperature history
	brick_temp_trend = OpenStudio::Model::EnergyManagementSystemTrendVariable.new(model,average_brick_temp)
  brick_temp_trend.setName("#{my_atc.name}_t_bricks_past")
  brick_temp_trend.setNumberOfTimestepsToBeLogged(144)

	# Create new EnergyManagementSystem:TrendVariable object and configure to hold outdoor temperature
	oa_dbt_trend = OpenStudio::Model::EnergyManagementSystemTrendVariable.new(model, oa_dbt_sen)
	oa_dbt_trend.setName("#{my_atc.name}_t_ext_past")
  oa_dbt_trend.setNumberOfTimestepsToBeLogged(144)
  #-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
                                                                                                # Create initilization program
  #-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

	initprogram = OpenStudio::Model::EnergyManagementSystemProgram.new(model)
    initprogram.setName("#{my_atc.name}_initATCThermElectModel")
    body = <<-EMS
	SET #{atc_nameplate_power.name} = 80000
	SET #{maximum_building_power.name} = #{p_max_sen.name}
  SET #{brick_init_temp.name} = #{initial_temperature}
	SET #{maximum_brick_temp.name} = #{storage_Temperature_High_Limit}
	SET #{minimum_brick_temp.name} = #{storage_Temperature_Low_Limit}
	SET #{maximum_outdoor_temp.name} = #{maximum_Outdoor_Temperature}
	SET #{minimum_outdoor_temp.name} = #{minimum_Outdoor_Temperature}
  SET #{average_brick_temp.name} = #{brick_init_temp.name}
  SET #{brick_temp_trend.name} = #{brick_init_temp.name}
  SET #{brick_target_core_temp.name} = #{maximum_brick_temp.name}
	SET #{brick_core_mass.name} = 2340.5
	SET #{brick_specific_heat.name} = 920
	SET #{brick_heat_loss_coeff.name} = 4.5
	SET #{cont_prop_gain.name} = 0.008
	SET #{cont_prop_offset.name} = 0.1
	SET #{brick_setpoint_error.name} = #{brick_target_core_temp.name} - #{average_brick_temp.name}
	SET #{atc_charging_auth.name} = #{aut_char_sen.name}
	SET #{atc_discharging_auth.name} = #{aut_dischar_sen.name}
  SET #{available_charging_power.name} = 0
	SET #{cont_output_init.name} = 0
	SET #{cont_output_fin.name} = 0
	SET #{cont_prop_sig_init.name} = 0
	SET #{cont_prop_cont_sig_fin.name}= 0
	SET #{storage_heating_pwr.name} = 0
	SET #{storage_loss_pwr.name} = 0
	SET #{storage_electric_pwr.name} = 0
	SET #{htf_specific_heat.name} = #{cp_int_var.name}
  SET #{htf_density.name} = #{rho_int_var.name}
  SET #{vdot_des_act.name} = #{hw_plant_vdot_des.name}
	SET #{mdot_min_act.name} = 0
	SET #{mdot_max_act.name} = #{htf_density.name} * #{hw_plant_vdot_des.name}
	SET #{mdot_req_act.name} = #{mass_Flow_Rate}
	SET #{cap_min_act.name} = 0
  SET c1 = -0.0000105
	SET c2 = 0.0232
	SET c3 = -0.188
	SET #{cap_max_act.name} = (#{mdot_req_act.name}* #{cp_int_var.name})*(c1 * (#{maximum_brick_temp.name} ^ 2) + c2 * #{maximum_brick_temp.name} + c3)
	SET #{cap_opt_act.name} = #{cap_max_act.name}
	SET #{tout_act.name} = #{tin_int_var.name} + #{cap_max_act.name} / ( #{mdot_req_act.name}* #{htf_specific_heat.name})

    EMS
    initprogram.setBody(body)
	my_atc.setPlantInitializationProgram(initprogram)

	# initialization programs program calling mananger
	initpcm = OpenStudio::Model::EnergyManagementSystemProgramCallingManager.new(model)
  initpcm.setName("#{my_atc.name}_ThermElect_Init_Programs")
  initpcm.setCallingPoint('UserDefinedComponentModel')
  initpcm.addProgram(initprogram)

  #-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
	                                                                                                              # Create simulation program
  #-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

	simprogram = OpenStudio::Model::EnergyManagementSystemProgram.new(model)
    simprogram.setName("#{my_atc.name}_SimATCThermElectModel")
    body = <<-EMS
	SET initial_temp_of_last_iteration = #{brick_init_temp.name}
	SET final_temp_of_last_iteration = #{average_brick_temp.name}

	SET initial_timestamp_of_last_iteration = #{prevtimestepbegintime.name}
	SET final_timestamp_of_last_iteration =  #{prevtimestependtime.name}

	SET initial_timestamp_of_current_iteration = CurrentTime - SystemTimeStep
	SET final_timestamp_of_current_iteration = CurrentTime

	IF initial_timestamp_of_current_iteration == initial_timestamp_of_last_iteration
		SET reiteration_flag = 1
		SET #{brick_init_temp.name} = initial_temp_of_last_iteration
	ELSE
		SET reiteration_flag = 0
		SET #{brick_init_temp.name} = #{average_brick_temp.name}
	ENDIF


	SET #{systimestep.name} = SystemTimeStep
	SET #{prevtimestependtime.name} = CurrentTime
	SEt #{prevtimestepbegintime.name} = CurrentTime - SystemTimeStep
	SET #{building_power_dmd.name} = @Trendaverage #{elec_dmd_sen.name} 2
	SET #{maximum_building_power.name} = #{p_max_sen.name}
	SET #{available_charging_power.name} = #{maximum_building_power.name} - #{building_power_dmd.name}
	SET alphaavail = #{available_charging_power.name}/#{atc_nameplate_power.name}
	IF #{available_charging_power.name} > 0
	   SET  #{cont_output_init.name} =@MIN 1 alphaavail
	ELSE
	   SET #{cont_output_init.name} = 0
	ENDIF

  SET text = @TrendMin #{oa_dbt_trend.name} 96
	SET tmax = #{maximum_brick_temp.name}
	SET tmin = #{minimum_brick_temp.name}
	SET textmin = #{minimum_outdoor_temp.name}
	SET textmax = #{maximum_outdoor_temp.name}

	IF text < textmin
	   SET #{brick_target_core_temp.name} = tmax
	ELSEIF text > textmax
	   SET #{brick_target_core_temp.name} = tmin
	ELSE
	   SET #{brick_target_core_temp.name} = ((tmax - tmin)/(textmin - textmax))*text + (tmax - ((tmax - tmin)/(textmin - textmax))*textmin)
	ENDIF

	SET #{cont_prop_gain.name} = 0.008
	SET #{cont_prop_offset.name} = 0.1

	SET #{brick_setpoint_error.name} = #{brick_target_core_temp.name} - #{brick_init_temp.name}
	SET #{cont_prop_sig_init.name} = #{cont_prop_gain.name} * #{brick_setpoint_error.name} + #{cont_prop_offset.name}
	IF #{cont_prop_sig_init.name} > 1
	   SET #{cont_prop_sig_init.name} = 1
	ELSEIF #{cont_prop_sig_init.name} < 0
	   SET #{cont_prop_sig_init.name} = 0
	ENDIF

	SET #{cont_prop_cont_sig_fin.name} = @MIN #{cont_output_init.name} #{cont_prop_sig_init.name}
	SET #{cont_output_fin.name} = @MAX 0 #{cont_prop_cont_sig_fin.name}

  SET #{atc_charging_auth.name} = #{aut_char_sen.name}
	SET #{storage_electric_pwr.name} = #{atc_charging_auth.name} * #{cont_output_fin.name} * #{atc_nameplate_power.name}
	SET #{storage_electric_ener.name} = #{storage_electric_pwr.name} * SystemTimeStep * 3600

	SET c1 = -0.0000105
	SET c2 = 0.0232
	SET c3 = 0.188
  SET #{atc_discharging_auth.name} = #{aut_dischar_sen.name}
  SET Tliminf = 93
  IF #{brick_init_temp.name} <=Tliminf
    SET #{atc_discharging_auth.name} = 0
  ENDIF

	SET #{cap_max_act.name} = #{mass_Flow_Rate}*#{cp_int_var.name}*(c1 * (#{brick_init_temp.name} ^ 2) + c2 * #{brick_init_temp.name} - c3)
	SET #{maximum_loading_cap.name} = #{cap_max_act.name}
	SET #{cap_opt_act.name} = #{cap_max_act.name}
	SET #{max_brick_heating_capacity.name} = #{cap_max_act.name}
	SET #{load_req_ets.name} = #{load_int_var.name}

	SET hw_cp = #{cp_int_var.name}
  SET hw_rho = #{rho_int_var.name}


	SET #{tout_max_act.name} = 100.0
	IF (#{load_int_var.name} <= 0)
  	SET #{mdot_req_act.name} = 0
  	SET #{storage_heating_pwr.name} = 0
  	SET #{tout_act.name} = #{tin_int_var.name}
	ELSE
  	SET #{mdot_req_act.name} = #{mass_Flow_Rate}
  	SET #{storage_heating_pwr.name} = #{atc_discharging_auth.name} * (@MIN #{cap_max_act.name} #{load_int_var.name})
  	SET #{tout_act.name} = #{tin_int_var.name} + #{storage_heating_pwr.name}/(#{mdot_req_act.name}*hw_cp)
	ENDIF

	SET #{storage_heating_ener.name} = #{storage_heating_pwr.name} * SystemTimeStep * 3600

	SET #{storage_loss_pwr.name} = #{brick_heat_loss_coeff.name} * (#{brick_init_temp.name} - #{amb_zone_temp_sen.name})
	SET #{q_sensible_heat_loss_act.name} = #{storage_loss_pwr.name}
	SET #{storage_loss_ener.name} = #{storage_loss_pwr.name} * SystemTimeStep * 3600

	IF WarmupFlag == 1
		SET #{storage_electric_pwr.name} = (#{storage_heating_pwr.name}+#{storage_loss_pwr.name})
	ENDIF

	SET #{average_brick_temp.name} = #{brick_init_temp.name} + (SystemTimeStep * 3600)/(#{brick_core_mass.name}*#{brick_specific_heat.name}) * (#{storage_electric_pwr.name} - #{storage_heating_pwr.name} - #{storage_loss_pwr.name})
  EMS
  simprogram.setBody(body)
	simpcm = OpenStudio::Model::EnergyManagementSystemProgramCallingManager.new(model)
  simpcm.setName("#{my_atc.name}_ThermElect_Sim_Programs")
  simpcm.setCallingPoint('UserDefinedComponentModel')
  simpcm.addProgram(simprogram)
	my_atc.setPlantSimulationProgram(simprogram)

	# set program calling managers and programs
  my_atc.setPlantInitializationProgramCallingManager(initpcm)
  my_atc.setPlantSimulationProgramCallingManager(simpcm)

  # EMS output
	output_ems = model.getOutputEnergyManagementSystem
	output_ems.setEMSRuntimeLanguageDebugOutputLevel("None")
	#output_ems.setEMSRuntimeLanguageDebugOutputLevel("Verbose")

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
                                                                                                  # CUSTOM OUTPUT VARIABLES
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

  # Average brick temperature (current)
  eout_average_brick_temp = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, average_brick_temp)
  eout_average_brick_temp.setName("#{my_atc.name}_Brick_Temperature")
  eout_average_brick_temp.setEMSVariableName("#{average_brick_temp.name}")
  eout_average_brick_temp.setUnits("C")
  eout_average_brick_temp.setTypeOfDataInVariable("Averaged")
  eout_average_brick_temp.setUpdateFrequency("SystemTimeStep")
  v = OpenStudio::Model::OutputVariable.new("#{eout_average_brick_temp.name}", model)
  v.setName("#{eout_average_brick_temp.name}")
  v.setReportingFrequency(report_freq)

  # maximum heating capacity
  eout_max_brick_heating_capacity = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, max_brick_heating_capacity)
  eout_max_brick_heating_capacity.setName("#{my_atc.name}_Maximum_Heating_Capacity")
  eout_max_brick_heating_capacity.setEMSVariableName("#{max_brick_heating_capacity.name}")
  eout_max_brick_heating_capacity.setUnits("W")
  eout_max_brick_heating_capacity.setTypeOfDataInVariable("Averaged")
  eout_max_brick_heating_capacity.setUpdateFrequency("SystemTimeStep")
  v = OpenStudio::Model::OutputVariable.new("#{eout_max_brick_heating_capacity.name}", model)
  v.setName("#{eout_max_brick_heating_capacity.name}")
  v.setReportingFrequency(report_freq)

  # Target brick temperature
  eout_target_brick_temp = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, brick_target_core_temp)
  eout_target_brick_temp.setName("#{my_atc.name}_Brick_Target_Core_Temperature")
  eout_target_brick_temp.setEMSVariableName("#{brick_target_core_temp.name}")
  eout_target_brick_temp.setUnits("C")
  eout_target_brick_temp.setTypeOfDataInVariable("Averaged")
  eout_target_brick_temp.setUpdateFrequency("SystemTimeStep")
  v = OpenStudio::Model::OutputVariable.new("#{eout_target_brick_temp.name}", model)
  v.setName("#{eout_target_brick_temp.name}")
  v.setReportingFrequency(report_freq)

  # # Average brick temperature of previous timestep
  # eout_initial_brick_temp = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, brick_init_temp)
  # eout_initial_brick_temp.setName("#{my_atc.name}_Brick_Initial_Temperature")
  # eout_initial_brick_temp.setEMSVariableName("#{brick_init_temp.name}")
  # eout_initial_brick_temp.setUnits("C")
  # eout_initial_brick_temp.setTypeOfDataInVariable("Averaged")
  # eout_initial_brick_temp.setUpdateFrequency("SystemTimeStep")
  # v = OpenStudio::Model::OutputVariable.new("#{eout_initial_brick_temp.name}", model)
  # v.setName("#{eout_initial_brick_temp.name}")
  # v.setReportingFrequency(report_freq)

 # Mass flow rate requested by ETS
  eout_ets_mass_flow_rate = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, mdot_req_act)
  eout_ets_mass_flow_rate.setName("#{my_atc.name}_Mass_Flow_Rate")
  eout_ets_mass_flow_rate.setEMSVariableName("#{mdot_req_act.name}")
  eout_ets_mass_flow_rate.setUnits("kg/s")
  eout_ets_mass_flow_rate.setTypeOfDataInVariable("Averaged")
  eout_ets_mass_flow_rate.setUpdateFrequency("SystemTimeStep")
  v = OpenStudio::Model::OutputVariable.new("#{eout_ets_mass_flow_rate.name}", model)
  v.setName("#{eout_ets_mass_flow_rate.name}")
  v.setReportingFrequency(report_freq)

  # Electric power used by ATC
  eout_storage_electric_pwr = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, storage_electric_pwr)
  eout_storage_electric_pwr.setName("#{my_atc.name}_Electric_Power")
  eout_storage_electric_pwr.setEMSVariableName("#{storage_electric_pwr.name}")
  eout_storage_electric_pwr.setUnits("W")
  eout_storage_electric_pwr.setTypeOfDataInVariable("Averaged")
  eout_storage_electric_pwr.setUpdateFrequency("SystemTimeStep")
  v = OpenStudio::Model::OutputVariable.new("#{eout_storage_electric_pwr.name}", model)
  v.setName("#{eout_storage_electric_pwr.name}")
  v.setReportingFrequency(report_freq)

  # Maximum Allowed Building Electric Power
  eout_maximum_building_power = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, maximum_building_power)
  eout_maximum_building_power.setName("#{my_atc.name}_Maximum_Allowed_Building_Peak_Power")
  eout_maximum_building_power.setEMSVariableName("#{maximum_building_power.name}")
  eout_maximum_building_power.setUnits("W")
  eout_maximum_building_power.setTypeOfDataInVariable("Averaged")
  eout_maximum_building_power.setUpdateFrequency("SystemTimeStep")
  v = OpenStudio::Model::OutputVariable.new("#{eout_maximum_building_power.name}", model)
  v.setName("#{eout_maximum_building_power.name}")
  v.setReportingFrequency(report_freq)

  # Available charging power
  eout_available_charging_power = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, available_charging_power)
  eout_available_charging_power.setName("#{my_atc.name}_Available_Charging_Power_for_ATC")
  eout_available_charging_power.setEMSVariableName("#{available_charging_power.name}")
  eout_available_charging_power.setUnits("W")
  eout_available_charging_power.setTypeOfDataInVariable("Averaged")
  eout_available_charging_power.setUpdateFrequency("SystemTimeStep")
  v = OpenStudio::Model::OutputVariable.new("#{eout_available_charging_power.name}", model)
  v.setName("#{eout_available_charging_power.name}")
  v.setReportingFrequency(report_freq)


  # Charging authorization (schedule value)
  eout_atc_charging_auth = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, atc_charging_auth)
  eout_atc_charging_auth.setName("#{my_atc.name}_Scheduled_Charging_Authorization")
  eout_atc_charging_auth.setEMSVariableName("#{atc_charging_auth.name}")
  #eout_atc_charging_auth.setUnits("")
  eout_atc_charging_auth.setTypeOfDataInVariable("Averaged")
  eout_atc_charging_auth.setUpdateFrequency("SystemTimeStep")
  v = OpenStudio::Model::OutputVariable.new("#{eout_atc_charging_auth.name}", model)
  v.setName("#{eout_atc_charging_auth.name}")
  v.setReportingFrequency(report_freq)

  # Discharging authorization (schedule value)
  eout_atc_discharging_auth = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, atc_discharging_auth)
  eout_atc_discharging_auth.setName("#{my_atc.name}_Scheduled_Discharging_Authorization")
  eout_atc_discharging_auth.setEMSVariableName("#{atc_discharging_auth.name}")
  #eout_atc_charging_auth.setUnits("")
  eout_atc_discharging_auth.setTypeOfDataInVariable("Averaged")
  eout_atc_discharging_auth.setUpdateFrequency("SystemTimeStep")
  v = OpenStudio::Model::OutputVariable.new("#{eout_atc_discharging_auth.name}", model)
  v.setName("#{eout_atc_discharging_auth.name}")
  v.setReportingFrequency(report_freq)

  # # proportional controler signal
  # eout_cont_prop_cont_sig_fin  = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, cont_prop_cont_sig_fin )
  # eout_cont_prop_cont_sig_fin.setName("#{my_atc.name}_Proportional_Controler_Signal")
  # eout_cont_prop_cont_sig_fin.setEMSVariableName("#{cont_prop_cont_sig_fin.name}")
  # #eout_cont_prop_cont_sig_fin.setUnits("C")
  # eout_cont_prop_cont_sig_fin.setTypeOfDataInVariable("Averaged")
  # eout_cont_prop_cont_sig_fin.setUpdateFrequency("SystemTimeStep")
  # v = OpenStudio::Model::OutputVariable.new("#{eout_cont_prop_cont_sig_fin.name}", model)
  # v.setName("#{eout_cont_prop_cont_sig_fin.name}")
  # v.setReportingFrequency(report_freq)
  #
  # # available power control signal
  # eout_cont_avail  = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, cont_output_init )
  # eout_cont_avail.setName("#{my_atc.name}_ElecPwr_Controler_Signal")
  # eout_cont_avail.setEMSVariableName("#{cont_output_init.name}")
  #  #eout_cont_prop_cont_sig_fin.setUnits("C")
  # eout_cont_avail.setTypeOfDataInVariable("Averaged")
  # eout_cont_avail.setUpdateFrequency("SystemTimeStep")
  #  v = OpenStudio::Model::OutputVariable.new("#{eout_cont_avail.name}", model)
  #  v.setName("#{eout_cont_avail.name}")
  #  v.setReportingFrequency(report_freq)
  #
  # # Final control signal for electric power
  # eout_cont_output_fin  = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, cont_output_fin )
  # eout_cont_output_fin.setName("#{my_atc.name}_final_Control_Signal")
  # eout_cont_output_fin.setEMSVariableName("#{cont_output_fin.name}")
  # #eout_cont_output_fin.setUnits("C")
  # eout_cont_output_fin.setTypeOfDataInVariable("Averaged")
  # eout_cont_output_fin.setUpdateFrequency("SystemTimeStep")
  # v = OpenStudio::Model::OutputVariable.new("#{eout_cont_output_fin.name}", model)
  # v.setName("#{eout_cont_output_fin.name}")
  # v.setReportingFrequency(report_freq)

  # Metered Electric energy
  eout_storage_electric_ener  = OpenStudio::Model::EnergyManagementSystemMeteredOutputVariable.new(model, storage_electric_ener )
  eout_storage_electric_ener.setName("#{my_atc.name}_Electric_Energy")
  eout_storage_electric_ener.setEMSVariableName("#{storage_electric_ener.name}")
  eout_storage_electric_ener.setUnits("J")
  # eout_storage_electric_ener.setTypeOfDataInVariable("Summed")
  eout_storage_electric_ener.setUpdateFrequency("SystemTimeStep")
  eout_storage_electric_ener.setResourceType("Electricity")
  eout_storage_electric_ener.setGroupType("Plant")
  eout_storage_electric_ener.setEndUseCategory("Heating")
  v = OpenStudio::Model::OutputVariable.new("#{eout_storage_electric_ener.name}", model)
  v.setName("#{eout_storage_electric_ener.name}")
  v.setReportingFrequency(report_freq)

  # Thermal power delivered by ATC
  eout_storage_heating_pwr = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, storage_heating_pwr)
  eout_storage_heating_pwr.setName("#{my_atc.name}_Delivered_Thermal_Power")
  eout_storage_heating_pwr.setEMSVariableName("#{storage_heating_pwr.name}")
  eout_storage_heating_pwr.setUnits("W")
  eout_storage_heating_pwr.setTypeOfDataInVariable("Averaged")
  eout_storage_heating_pwr.setUpdateFrequency("SystemTimeStep")
  v = OpenStudio::Model::OutputVariable.new("#{eout_storage_heating_pwr.name}", model)
  v.setName("#{eout_storage_heating_pwr.name}")
  v.setReportingFrequency(report_freq)

  #heating_power_dmd / load request for ETS
  eout_load_req_ets = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, load_req_ets)
  eout_load_req_ets.setName("#{my_atc.name}_RequestedLoad")
  eout_load_req_ets.setEMSVariableName("#{load_req_ets.name}")
  eout_load_req_ets.setUnits("W")
  eout_load_req_ets.setTypeOfDataInVariable("Averaged")
  eout_load_req_ets.setUpdateFrequency("SystemTimeStep")
  v = OpenStudio::Model::OutputVariable.new("#{load_req_ets.name}", model)
  v.setName("#{load_req_ets.name}")
  v.setReportingFrequency(report_freq)

  # #ets maximum loading cap actuator value
  # eout_maximum_loading_cap = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, maximum_loading_cap)
  # eout_maximum_loading_cap.setName("#{my_atc.name}_MaximumLoadingCapacityCapValue")
  # eout_maximum_loading_cap.setEMSVariableName("#{maximum_loading_cap.name}")
  # eout_maximum_loading_cap.setUnits("W")
  # eout_maximum_loading_cap.setTypeOfDataInVariable("Averaged")
  # eout_maximum_loading_cap.setUpdateFrequency("SystemTimeStep")
  # v = OpenStudio::Model::OutputVariable.new("#{maximum_loading_cap.name}", model)
  # v.setName("#{maximum_loading_cap.name}")
  # v.setReportingFrequency(report_freq)
  #
  # # maximum loading capacity
  # eout_maximumloadingcapacity = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, max_cap_actuator_var)
  # eout_maximumloadingcapacity.setName("#{my_atc.name}_MaximumLoadingCapacity")
  # eout_maximumloadingcapacity.setEMSVariableName("#{max_cap_actuator_var.name}")
  # eout_maximumloadingcapacity.setUnits("W")
  # eout_maximumloadingcapacity.setTypeOfDataInVariable("Averaged")
  # eout_maximumloadingcapacity.setUpdateFrequency("SystemTimeStep")
  # v = OpenStudio::Model::OutputVariable.new("#{max_cap_actuator_var.name}", model)
  # v.setName("#{max_cap_actuator_var.name}")
  # v.setReportingFrequency(report_freq)

  # Thermal Energy delivered by ATC
  eout_storage_heating_ener = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, storage_heating_ener)
  eout_storage_heating_ener.setName("#{my_atc.name}_Heating_Rate")
  eout_storage_heating_ener.setEMSVariableName("#{storage_heating_ener.name}")
  eout_storage_heating_ener.setUnits("W")
  eout_storage_heating_ener.setTypeOfDataInVariable("Summed")
  eout_storage_heating_ener.setUpdateFrequency("SystemTimeStep")
  v = OpenStudio::Model::OutputVariable.new("#{storage_heating_ener.name}", model)
  v.setName("#{storage_heating_ener.name}")
  v.setReportingFrequency(report_freq)


  # ATC power loss
  eout_storage_loss_pwr = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, storage_loss_pwr)
  eout_storage_loss_pwr.setName("#{my_atc.name}_Thermal_Power_Loss")
  eout_storage_loss_pwr.setEMSVariableName("#{storage_loss_pwr.name}")
  eout_storage_loss_pwr.setUnits("W")
  eout_storage_loss_pwr.setTypeOfDataInVariable("Averaged")
  eout_storage_loss_pwr.setUpdateFrequency("SystemTimeStep")
  v = OpenStudio::Model::OutputVariable.new("#{eout_storage_loss_pwr.name}", model)
  v.setName("#{eout_storage_loss_pwr.name}")
  v.setReportingFrequency(report_freq)

 # ATC energy loss
  eout_storage_loss_ener = OpenStudio::Model::EnergyManagementSystemOutputVariable.new(model, storage_loss_ener)
  eout_storage_loss_ener.setName("#{my_atc.name}_Thermal_Energy_Loss")
  eout_storage_loss_ener.setEMSVariableName("#{storage_loss_ener.name}")
  eout_storage_loss_ener.setUnits("J")
  eout_storage_loss_ener.setTypeOfDataInVariable("Summed")
  eout_storage_loss_ener.setUpdateFrequency("SystemTimeStep")
  v = OpenStudio::Model::OutputVariable.new("#{eout_storage_loss_ener.name}", model)
  v.setName("#{eout_storage_loss_ener.name}")
  v.setReportingFrequency(report_freq)

#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
                                                                              # PLANT EQUIPMENT OPERATION SCHEMES
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

	# retrieve all electric thermal storage devices in the model # these could be identified from their unique type :PlantComponentUserDefined and a prefix "SimETS"
	pcudobjects = model.getPlantComponentUserDefineds
	electric_thermal_storage_equipment_list = []

	if !pcudobjects.empty?
		pcudobjects.each do |object|
		parts = object.name.to_s.split(/_/, 2)
		identifier = parts[0]
		if identifier == "SimETS"
			electric_thermal_storage_equipment_list.push(object)
		end
		end

	end

	highest_priority_equipment =[] # these refer to electric boilers
	lowest_priority_equipment=[]   # these refer to fossil fuel fired boilers

	if !boilers.empty?
		boilers.each do |b|
			if  b.fuelType() == 'Electricity'
				highest_priority_equipment.push(b)
			else
				lowest_priority_equipment.push(b)
			end
		end
	end


  htg_op_scheme = OpenStudio::Model::PlantEquipmentOperationHeatingLoad.new(model)

	# Add highest priority equipment first
	highest_priority_equipment.each do |equip|
	htg_op_scheme.addEquipment(1000000000, equip)
	end

	# Add ETS devices
	electric_thermal_storage_equipment_list.each do |equip|
	htg_op_scheme.addEquipment(1000000000, equip)
	end

	# Add lowest priority equipment last
	lowest_priority_equipment.each do |equip|
	htg_op_scheme.addEquipment(1000000000, equip)
	end

  user_selected_loop.setPlantEquipmentOperationHeatingLoad(htg_op_scheme)

    return true
  end # end the run method

end # end the measure

AddCentralElectricThermalStorageV2.new.registerWithApplication
