
-- label = tab title overrides 

local function home()
    return (os.getenv("USERPROFILE") or ""):gsub("\\", "/")
end


return {
    {
        label = "1",
        cwd = home(),
    },
    {
        label = "2",
        cwd = home(),
       
    }
    
}
