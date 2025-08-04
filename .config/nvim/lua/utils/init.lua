local utils = {
  "marks",
}

for _, util in ipairs(utils) do
  pcall(require, "util." .. util)
end
