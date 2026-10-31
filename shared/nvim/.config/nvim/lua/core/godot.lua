-- In a Godot project, listen on a fixed pipe so the Godot editor's
-- "Use External Editor" can open files in this Neovim via --server.
if vim.fn.filereadable(vim.fn.getcwd() .. "/project.godot") == 1 then
  -- pcall: a second Neovim in the same project can't reuse the pipe
  pcall(vim.fn.serverstart, "/tmp/godot-nvim.pipe")
end
