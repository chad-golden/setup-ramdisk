[![Tests](https://github.com/chad-golden/setup-ramdisk/actions/workflows/test.yml/badge.svg)](https://github.com/chad-golden/setup-ramdisk/actions/workflows/test.yml) 
[![Benchmark](https://github.com/chad-golden/setup-ramdisk/actions/workflows/benchmark.yml/badge.svg)](https://github.com/chad-golden/setup-ramdisk/actions/workflows/benchmark.yml)

# Setup RAM disk action
An action to setup high performance CI/CD storage using a RAM-backed disk on Windows. Consider using super-fast RAM-based storage if your CI/CD workflows are constrained by heavy I/O and you have enough RAM to spare.

## ⚠️ Important
RAM-based storage drivers used in this action are ***neither*** guaranteed to work ***nor*** guaranteed to provide a speed-up in all scenarios. Test your workflows carefully.

## Prerequisites
- Windows runner (e.g. Windows Server 2019, Windows Server 2022, or Windows Server 2025)
- Sufficient available RAM for your specified disk size
- PowerShell 7 (pwsh.exe, automatically available on GitHub-hosted runners)

## Usage

### Setup Action

Add the following step to your workflow:

```yaml
- name: Setup RAM Disk
  uses: chad-golden/setup-ramdisk@v1
  with:
    size-in-mb: 2048    # Optional: Default is 2048
    drive-letter: 'R'   # Optional: Default is R
    copy-workspace: false # Optional: Default is false
```

### Dismount Action

To clean up the RAM disk after use, add the dismount action:

```yaml
- name: Dismount RAM Disk
  uses: chad-golden/setup-ramdisk/dismount@v1
  with:
    drive-letter: 'R'   # Optional: Default is R
```

## Configuration Options

### Setup Action

| Input | Description | Default | Required |
|-------|-------------|---------|----------|
| `install` | Install ImDisk if not present | `true` | No |
| `size-in-mb` | RAM disk size in megabytes | `2048` | No |
| `drive-letter` | Drive letter for RAM disk (without colon) | `R` | No |
| `copy-workspace` | Copy workspace to RAM disk | `false` | No |

### Dismount Action

| Input | Description | Default | Required |
|-------|-------------|---------|----------|
| `drive-letter` | Drive letter to dismount (without colon) | `R` | No |

## Performance Considerations
- Ensure your workflow has enough memory available for both the RAM disk and your processes
- The RAM disk is volatile; data will be lost when the workflow completes
- Consider the time needed to copy data to/from the RAM disk when setting up your workflow

## Dependencies
- ImDisk v2.1.1, see more details [here](https://github.com/chad-golden/setup-ramdisk/blob/main/external/imdisk/README.md).
  - The installation package (imdisk.zip) is verified using SHA-256: `0558DDD7B751CC29B4530E5B85F86344A4E4FA5A91D16C5479F0A4470AADEF23`

## Benchmarks
[![Benchmark](https://github.com/chad-golden/setup-ramdisk/actions/workflows/benchmark.yml/badge.svg)](https://github.com/chad-golden/setup-ramdisk/actions/workflows/benchmark.yml)

This action includes automated performance benchmarks that run on different Windows runner images. The benchmarks measure I/O performance using Microsoft's DiskSpd tool with the following parameters:

- File size: 10MB
- Block size: 4K
- Thread count: 4
- Queue depth: 32
- Duration: 30 seconds (with 30 seconds warmup)
- Random read workload

The benchmark compares three storage options:
- C: drive (OS disk)
- D: drive (temp storage, when available)
- R: drive (RAM disk)

View the latest benchmark results by clicking the badge above or visiting the Actions tab.

### Example Benchmark Results (windows-2022) 📊
Here are the IOPS results for each drive tested during the benchmark run:

| Drive                  |     IOPS     |
|:-----------------------|-------------:|
| C: (OS)        | 5872.04 |
| D: (temp)      | 6782.99 |
| R: (RAM disk)  | 247421.30 |
