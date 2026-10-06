# Blood pressure estimation from lagged radial pressure

MATLAB code for estimating an aortic pressure waveform from a radial pressure waveform using a linear model trained with sequential or full-batch least-mean-square (LMS) updates.

## Quick start

Download or clone this repository, open MATLAB, and change to the repository folder:

```matlab
main
```

The example trains on the first 70% of the supplied recording and evaluates on the remaining 30%. It prints RMSE, MAE, Pearson correlation and a training-mean baseline RMSE, then plots measured and estimated aortic pressure. The calculation uses core MATLAB functions; no specialised toolbox is required.

To run without plotting, or change the configuration:

```matlab
data = load('blood_pressure.mat');
result = estimate_pressure(data.radial_data, data.aortic_data, ...
    'Method', 'online', 'Order', 20, 'SampleRate', 200);

batch = estimate_pressure(data.radial_data, data.aortic_data, ...
    'Method', 'batch', 'LearningRate', 2e-7, 'Epochs', 10000);
```

`main.m` resolves the bundled data relative to its own location. When calling `estimate_pressure` directly from another folder, add the repository to the MATLAB path and supply your own data or an absolute data path.

## Model and alignment

For radial pressure `r` and aortic pressure `a`, the model is:

```text
estimated_a(t) = w(1)*r(t-1) + ... + w(p)*r(t-p)
```

Although the original project called this an AR model, this implementation is more precisely a lagged-input linear regression (FIR model): it uses past radial pressure, not past aortic pressure. It has no intercept, scaling, filtering or time-delay calibration.

`arlag(r,N,p)` returns `N-p` rows. Row `j` corresponds to target sample `t=p+j` and contains `[r(t-1), ..., r(t-p)]`. Accordingly, the training targets start at `a(p+1)`. This corrects the previous code's pairing of those rows with targets starting at `a(1)`.

The split is chronological. Coefficients are fitted using training targets only and frozen for testing. The first test prediction uses the preceding `p` radial samples from the training interval; subsequent predictions can use already observed test radial samples. No future radial samples or held-out aortic targets are used as predictors. This preserves every test target and represents sequential prediction with available radial history.

## Options

| Name | Default | Meaning |
| --- | --- | --- |
| `Order` | `20` | Number of past radial samples per prediction |
| `TrainFraction` | `0.7` | Fraction used for training; sample count is rounded down |
| `SampleRate` | `200` | Sampling rate in Hz; used for timestamps, not resampling |
| `Method` | `'online'` | `'online'` or `'batch'` |
| `LearningRate` | `2e-4` online; `2e-7` batch | Initial step size |
| `Epochs` | `10000` | Full-batch iterations; unused for online mode |

Inputs must be finite real numeric vectors of equal length. Row and column vectors are accepted. The training interval must contain more than `Order` samples and leave at least one test sample.

Both solvers retain the original diminishing step size `mu/k`:

- **Online:** one sequential pass, one update per training sample. It does not adapt during the test interval.
- **Batch:** each update uses the sum of gradients across all training samples, not their mean. Learning-rate behaviour therefore depends on training-set size as well as signal scale.

The learning rates are inherited example settings, not optimised values. Nonfinite coefficients cause an explicit error, but finite coefficients alone do not imply convergence. Select model order and learning rate using a validation interval within the training portion; reserve the test interval for final evaluation.

## Data and outputs

`blood_pressure.mat` contains two `1 x 2000` double arrays:

| Variable | Role |
| --- | --- |
| `radial_data` | Radial pressure input |
| `aortic_data` | Aortic pressure target |

The original script documents 200 Hz sampling and a 10-second recording. With the defaults, there are 1,400 training samples, 1,380 usable training pairs and 600 test predictions. Time is zero-based (`(sample_index-1)/Fs`), so the test timestamps run from 7.000 to 9.995 seconds.

The repository does not document the data source, participant details, acquisition device, units, synchronisation procedure or redistribution terms.

`result` includes `coefficients`, `test_indices`, `time`, `target`, `prediction`, `rmse`, `mae`, `correlation`, `baseline_prediction`, `baseline_rmse`, `n_train` and `config`. RMSE and MAE use the original signal units. Correlation is `NaN` when either signal is constant or there is only one test sample. The baseline predicts the mean of the usable training aortic targets for every test sample.

The bundled record supports a within-record demonstration only. It does not establish generalisation to new participants or clinical accuracy. Correlation should be interpreted alongside absolute errors and the baseline.

## Files

| File | Purpose |
| --- | --- |
| `main.m` | Example, printed metrics and waveform plot |
| `estimate_pressure.m` | Configurable fitting and evaluation without plotting |
| `arlag.m` | Past-sample lag matrix |
| `onlinelms.m` | Sequential LMS coefficient history |
| `batchlms.m` | Full-batch coefficient history |
| `validate_lms_inputs.m` | Shared solver input checks |
| `tests/run_tests.m` | Alignment, update, validation and data smoke checks |

The original `arlag`, `onlinelms` and `batchlms` calling signatures remain available. Each solver returns the initial zero coefficients followed by every update, with the final coefficients in the last row.

## Regression checks

From the repository folder in MATLAB:

```matlab
addpath('tests');
run_tests
```

Or in GNU Octave:

```bash
octave --no-gui --quiet --eval "addpath('tests'); run_tests"
```

The GitHub Actions workflow runs these checks with Octave on pushes and pull requests. The checks include hand-calculated solver updates, a synthetic signal that detects target misalignment, boundary history, independence from held-out targets, input validation and the bundled dataset. GNU Octave is the CI execution target; MATLAB-specific execution should also be checked when a MATLAB installation is available.
