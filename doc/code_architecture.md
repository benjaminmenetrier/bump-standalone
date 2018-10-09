# Code architecture

- [Offline run](#offline_run)
- [Online run](#online_run)
  * [Setup](#setup)
  * [Run](#run)
  * [Apply](#apply)
    + [Get parameters](#get_parameters)
    + [Apply vertical balance operator](apply_vertical_balance_operator)
    + [Apply NICAS](#apply_nicas)
    + [Apply observation operator](#apply_observation_operator)
  * [Deallocate](#deallocate)

## Offline run

![](architecture/run_offline.svg)

## Online run

#### Setup

![](architecture/setup_online.svg)

#### Run

![](architecture/run_online.svg)

#### Apply

###### Get parameters

![](architecture/get_parameter.svg)

###### Apply vertical balance operator

![](architecture/apply_vbal.svg)

###### Apply NICAS

![](architecture/apply_nicas.svg)

###### Apply observation operator

![](architecture/apply_obsop.svg)

#### Deallocate

![](architecture/deallocation.svg)

# Drivers

![](architecture/drivers.svg)
