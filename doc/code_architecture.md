# Code architecture

- [Offline run](#offline-run)
- [Online run](#online-run)
  - [Setup](#setup)
  - [Run](#run)
  - [Apply](#apply)
    - [Get parameters](#get-parameters)
    - [Apply vertical balance operator](#apply-vertical-balance-operator)
    - [Apply NICAS](#apply-nicas)
    - [Apply observation operator](#apply-observation-operator)
  - [Deallocate](#deallocate)
- [Drivers](#drivers)


## Offline run

![](architecture/run_offline.svg)


## Online run


#### Setup

![](architecture/setup_online.svg)


#### Run

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


## Drivers

![](architecture/drivers.svg)
