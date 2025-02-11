### How It Works

1. **Parameter Handling:**  
   The function accepts one or more paths (via the `-Path` parameter or through the pipeline). It also accepts a `-Recurse` switch to control whether subdirectories are searched.

2. **Input Validation:**  
   Each provided path is checked with `Test-Path`. If a path does not exist, a warning is emitted and that path is skipped.

3. **Parallel Enumeration:**  
   For each valid path, a `[System.IO.DirectoryInfo]` object is created. The directories and files are enumerated using `EnumerateDirectories` and `EnumerateFiles` respectively, then converted into a parallel query using `AsParallel`.

4. **Output:**  
   The function concatenates the directories and files found and outputs them as a single collection.
