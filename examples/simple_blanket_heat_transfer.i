[Mesh]
  [fmg]
    type = FileMeshGenerator
    file = 'Meshes/Blanket_OneRow.msh'
  []
[]

[Outputs]
  exodus = true
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Steady
  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'hypre'
[]

[Variables]
  [temp]
    initial_condition = 800 # K
  []
[]

[Kernels]
  [conduction]
    type = HeatConduction
    variable = temp
  []
  [pd_shield]
    type = HeatSource
    variable = temp
    block = 'Shield'
    value = 2.7544e+06
  []
  [pd_fw]
    type = HeatSource
    variable = temp
    value = 4.6228e+05
    block = 'First_Wall'
  []
  [pd_mult]
    type = HeatSource
    variable = temp
    value = 6.4374e+05
    block = 'Multiplier'
  []
  [pd_ts]
    type = HeatSource
    variable = temp
    value = 6.3422e+05
    block = 'Toroidal_Plate'
  []
  [pd_breeder]
    type = HeatSource
    variable = temp
    value = 1.6260e+06
    block = 'Breeder'
  []
[]

[BCs]
  [FW_BC]
    type = NeumannBC
    variable = temp
    boundary = 'Heated_Surface'
    value = 305.61 # 0.25 MW/m^2 3202.5 for simple blanket mesh
  []

  [channel]
    type = DirichletBC
    variable = temp
    boundary = 'CH1 CH2 Back_Wall'
    value = 635
  []
[]

[Materials]
  [breeder_material_BZ_conductivity]
    type = HeatConductionMaterial
    thermal_conductivity_temperature_function = breeder
    temp = temp
    block = 'Breeder'
  []
  [multiplier_material_BZ_conductivity]
    type = HeatConductionMaterial
    thermal_conductivity_temperature_function = multiplier
    temp = temp
    block ='Multiplier'
  []
  [breeder_material_plate_conductivity]
    type = HeatConductionMaterial
    thermal_conductivity_temperature_function = F82H
    temp = temp
    block = 'First_Wall Toroidal_Plate'
  []
  [armor_material_conductivity]
    type = HeatConductionMaterial
    thermal_conductivity_temperature_function = tungsten
    temp = temp
    block = 'Shield'
  []
[]

[Functions]
  [./F82H]
    # Multiphyics modeling of the FW/Blanket of the US fusion nuclear science facility
    # Y. Huang,
    # Fig. 7
    type = PiecewiseLinear
    x = '293.93 390.03 491.33 592.63 696.53 779.64 865.36 943.28 1008.21 1067.96 1140.68' # K
    y = '24.46 23.04 21.33 19.24 16.77 14.49 11.93 9.37 6.80 4.34 1.30' # W/mK
  [../]

  [./breeder]
    # A Novel Cellular Breeding Material For Transformative Solid Breeder Blankets
    # S. Sharafat
    # Figure 18
    type = PiecewiseLinear
    x = '273.23 307.47 362.71 461.40 562.54 666.43 767.05 867.29 967.50 1070.53 1170.73 1268.15 1381.42 1480.19' # K
    y = '3.96 3.66 3.43 2.86 2.49 2.20 2.00 1.92 1.85 1.85 1.78 1.64 1.26 0.66' # W/mK
  [../]

  [./multiplier]
    # Thermal conductivity of neutron irradiated Be12Ti
    # M. Uchida
    # Fig. 6
    type = PiecewiseLinear
    x = '266.83 376.31 477.36 662.62 847.89 1049.99 1243.68' #K
    y = '12.96 18.31 19.44 22.82 25.07 32.96 50.42' # W/mK
  [../]
  [./tungsten]
    # Thermal properties of pure tungsten and its alloys for fusion applications
    # Makoto Fukuda
    # Fig. 5
    type = PiecewiseLinear
    x = '365.44 464.99 556.82 660.93 757.28 858.82 947.70 1115.15 1254.55 1343.22' #K
    y = '178.86 162.76 149.22 142.95 140.10 134.69 129.26 122.23 119.01 117.86' # W/mK
  [../] 
[]

[MultiApps]
  [tritium]
    type = FullSolveMultiApp
    input_files = 'tritium_diffusion.i'
  []
[]

[Transfers]
  [temp_tritium]
    type = MultiAppNearestNodeTransfer
    to_multi_app = tritium
    source_variable = temp
    variable = temperature
  []
[]
