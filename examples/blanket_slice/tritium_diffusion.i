Channels = 'CH1 CH2 CH3 CH4 CH5 CH6 CH7 CH8 CH9 CH10 CH11 CH12 CH13 CH14 CH15 CH16 CH17 CH18 CH19 CH20 CH21 CH22 CH23 CH24 CH25 CH26'

[Mesh]
    [fmg]
      type = FileMeshGenerator
      file = 'Blanket_Simple.msh'
    []
[]
  
[Outputs]
    exodus = true
    csv = true
[]

[VectorPostprocessors]
  [tritium_y]
    type = LineValueSampler
    start_point = '-0.01 0 0.0183'
    end_point = '-0.01 0.119 0.0183'
    num_points = 100
    variable = tritium
    sort_by = y
  []
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
    [tritium]
    []
[]
  
[Kernels]
    [diffusion]
      type = MatDiffusion
      variable = tritium
      diffusivity = diffusivity
    []
    [pd_breeder]
      type = BodyForce
      variable = tritium
      value = 1.411e-5
      block = 'Breeder'
    []
[]

#[InterfaceKernels]
  #[interface]
    #type = InterfaceSorptionSievert
    #K0 = 1e-4
    #temperature = temperature
    #diffusivity = diffusivity
    #variable = tritium
    #neighbor_var = tritium
    #boundary = ''
  #[]
#[]
  
[BCs]
  [channels]
    type = DirichletBC
    variable = tritium
    boundary = ${Channels}
    value = 1e-6
  []
  #[flux]
    #type = DirichletBC
    #variable = tritium
    #boundary = 'Heated_Surface'
    #value = 1e-6
  #[]
  #[flux_back]
    #type = DirichletBC
    #variable = tritium
    #boundary = 'Back_Wall'
    #value = 1e-6
  #[]
[]
  
[AuxVariables]
    [temperature]
    []
[]

[Materials]
  [plate_diffusivity_material]
    #Permeation of deuterium and tritium through the martensitic steel F82H
    #Yu.N. Dolinsky
    #Table 1
    type = ParsedMaterial
    property_name = diffusivity 
    expression = 3.3e-8*exp(-7.8/(8314*temperature))
    coupled_variables = temperature
    block = 'First_Wall Toroidal_Plate1 Toroidal_Plate2'
  []
  #[plate_diffusivity_material]
    #type = GenericConstantMaterial
    #prop_names = diffusivity
    #prop_values = 4.9e-8
    #block = 'First_Wall Toroidal_Plate1 Toroidal_Plate2'
  #[]
  [breeder_diffusivity_material]
    #Modeling of tritium release from irradiated Li2ZrO3
    #S.Beloglazov
    #Table 1
    type = ParsedMaterial
    property_name = diffusivity
    expression = 8.33e-5*exp(-125/(8314*temperature))
    coupled_variables = temperature
    block = 'Breeder'
  []
  #[breeder_diffusivity_material]
    #type = GenericConstantMaterial
    #prop_names = diffusivity
    #prop_values = 4.9e-8
    #block = 'Breeder'
  #[]
  [multiplier_diffusivity]
    #to do: Find a diffusivity term for the multiplier region
    type = GenericConstantMaterial
    prop_names = 'diffusivity' 
    prop_values = '4.9e-8' #m^2*s^-1
    block = 'Multiplier'
  []
  [shield_diffusivity]
    #TMAP8 json: zakharov hydrogen 1975
    #zakharov
    type = PiecewiseLinearInterpolationMaterial
    property = diffusivity
    variable = temperature
    x = '673.15 873.15 1073.15 1273.15 1473.15'
    y = '6.43e-12 4.22e-10 5.99e-9 3.67e-08 1.38e-07'
    block = 'Shield'
  []
  [Breeder_Solubility]
    type = ADGenericConstantMaterial
    prop_names = 'solubility'
    prop_values = '1e-3'
    block = 'Breeder'
  []
  [Structure_Solubility]
    type = ADGenericConstantMaterial
    prop_names = 'solubility'
    prop_values = '1e-2'
    block = 'Toroidal_Plate1 Toroidal_Plate2'
  []
[]

[FunctorMaterials]
  [interface_solubility]
    type = SolubilityRatioMaterial
    solubility_primary = solubility
    solubility_secondary = solubility
    concentration_primary = tritium
    concentration_secondary = tritium
    boundary = 'Breeder_surface'
  []
[]