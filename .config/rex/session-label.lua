-- Puts the repo's name in front so two repos' "main" checkouts don't share a session
return function(path)
  local name = path:match("([^/]+)/*$")
  local origin = rex.exec({ "git", "-C", path, "remote", "get-url", "origin" })
  local repo = origin and origin.ok and origin.stdout:match("([^/:%s]+)%s*$")
  repo = repo and repo:gsub("%.git$", "")
  if not repo or repo == name then return name end
  return repo .. "/" .. name
end
