# Passive Suspension Tuning: Ride Comfort vs Roadholding

This repository contains the MATLAB scripts and exported numerical results used for the Advanced Vibrations project **Passive Suspension Tuning: Ride Comfort vs Roadholding**.

The project investigates how passive suspension stiffness and damping influence ride comfort, roadholding, suspension travel, tyre deflection and pitch response. Three representative suspension setups are compared:

* Comfort-oriented road car
* Rally-oriented vehicle
* Track-oriented racing vehicle

Two vehicle vibration models are used:

* A 2-DOF quarter-car model for vertical ride response
* A half-car pitch model for body bounce, pitch motion and front/rear wheel input delay

## Repository structure

```text
AV-Suspension-Project/
│
├── MATLAB/
│   ├── quarter_car_initial_vibration_analysis_balanced_score_v2.m
│   └── half_car_pitch_initial_analysis.m
│
├── CSV_Quarter/
│   ├── quarter_car_parameters.csv
│   ├── quarter_car_natural_frequencies.csv
│   ├── quarter_car_bump_response_summary.csv
│   ├── quarter_car_sinusoidal_response_summary.csv
│   ├── quarter_car_frequency_response_wide.csv
│   ├── quarter_car_frequency_response_low_frequency.csv
│   ├── comfort_parameter_sweep.csv
│   ├── rally_parameter_sweep.csv
│   └── track_parameter_sweep.csv
│
├── CSV_Half/
│   ├── half_car_pitch_natural_frequencies.csv
│   ├── half_car_pitch_bump_response_summary.csv
│   └── half_car_pitch_frequency_response_summary.csv
│
├── Figures_Quarter/
│   └── exported quarter-car figure files
│
├── Figures_Half/
│   └── exported half-car figure files
│
├── .gitignore
└── README.md
```

## MATLAB scripts

### `quarter_car_initial_vibration_analysis_balanced_score_v2.m`

This script implements the quarter-car suspension model. It is used to:

* calculate quarter-car natural frequencies
* simulate bump response
* simulate sinusoidal road response
* perform frequency-response analysis
* run stiffness and damping parameter sweeps
* compare baseline and selected suspension parameters
* export figures and CSV result tables

The main response quantities are sprung-mass displacement, sprung-mass acceleration, suspension deflection and tyre deflection.

### `half_car_pitch_initial_analysis.m`

This script implements the half-car pitch model. It is used to:

* calculate half-car natural frequencies
* simulate front and rear bump inputs with wheelbase delay
* analyse body bounce and pitch response
* compare front and rear suspension deflection
* compare front and rear tyre deflection
* perform half-car frequency-response analysis
* export figures and CSV result tables

The main response quantities are body bounce, body bounce acceleration, pitch angle, front/rear suspension deflection and front/rear tyre deflection.

## Model parameters

The quarter-car model uses the following constant vehicle parameters:

| Parameter                 |       Value |
| ------------------------- | ----------: |
| Sprung mass, `ms`         |      290 kg |
| Unsprung mass, `mu`       |       40 kg |
| Tyre stiffness, `kt`      | 200,000 N/m |
| Bump height               |      0.04 m |
| Bump duration             |      0.12 s |
| Sinusoidal road amplitude |      0.02 m |
| Sinusoidal road frequency |      1.5 Hz |

The half-car model extends the quarter-car model using:

| Parameter                |       Value |
| ------------------------ | ----------: |
| Body mass, `mb`          |      580 kg |
| Front unsprung mass      |       40 kg |
| Rear unsprung mass       |       40 kg |
| Front tyre stiffness     | 200,000 N/m |
| Rear tyre stiffness      | 200,000 N/m |
| Front axle distance, `a` |       1.4 m |
| Rear axle distance, `b`  |       1.4 m |
| Wheelbase                |       2.8 m |
| Vehicle speed            |      10 m/s |

## Suspension setups

The baseline quarter-car suspension parameters are:

| Setup   | Suspension stiffness, `ks` | Damping coefficient, `cs` |
| ------- | -------------------------: | ------------------------: |
| Comfort |                 15,000 N/m |                1,200 Ns/m |
| Rally   |                 25,000 N/m |                2,000 Ns/m |
| Track   |                 40,000 N/m |                2,850 Ns/m |

The selected quarter-car suspension parameters are:

| Setup   | Selected stiffness, `ks` | Selected damping, `cs` |
| ------- | -----------------------: | ---------------------: |
| Comfort |               10,000 N/m |             1,150 Ns/m |
| Rally   |               18,000 N/m |             2,300 Ns/m |
| Track   |               30,000 N/m |             3,600 Ns/m |

## Running the scripts

1. Open MATLAB.
2. Open the relevant script from the `MATLAB/` folder.
3. Check the output folder path near the top of the script.
4. Update the output folder path if required.
5. Run the script.

The scripts automatically generate figures and CSV result tables.

## Outputs

The exported CSV files provide the numerical values used in the project report. These include:

* natural frequencies
* bump-response summaries
* sinusoidal-response summaries
* frequency-response data
* parameter-sweep results
* half-car pitch-response summaries

The figures generated by the scripts were used to support the results and discussion sections of the report.

## Notes on reproducibility

The scripts are intended to reproduce the results presented in the project report using the same model assumptions, parameters and road inputs. The models are simplified passive suspension models and are not intended to represent exact production vehicles.

The results should be interpreted as a comparative numerical study of suspension tuning behaviour rather than a validated real-vehicle suspension design.

## Authors

Elias Klestinis,
Zachary Earl

Advanced Vibrations Project,
University of Adelaide,
2026
