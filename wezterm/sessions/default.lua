return {
    {
        label = "Pwsh",
        cwd = (os.getenv("USERPROFILE") or ""):gsub("\\", "/"),
        args = { "pwsh.exe", "-NoLogo" },
    },
    {
        label = "Logs",
        cwd = "C:/",
        args = { "pwsh.exe", "-NoLogo" },
    }
}
