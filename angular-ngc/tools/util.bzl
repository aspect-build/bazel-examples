def to_manifest_path(ctx, file):
    if file.basename.startswith("../"):
        return file.basename[3:]
    else:
        return file.basename.replace(".ts", ".js")
