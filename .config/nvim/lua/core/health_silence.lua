local notify_original = vim.notify

vim.notify = function(msg, level, opts)
  -- Messages to suppress
  local suppress_patterns = {
    -- LSP position encoding warnings
    "position_encoding param is required",
    "Defaulting to position encoding of the first client",
    "multiple different client offset_encodings",

    -- Deprecated API warnings
    "vim.validate is deprecated",

    -- Which-key mini.icons missing
    "|mini.icons| is not installed",
  }

  for _, pattern in ipairs(suppress_patterns) do
    if msg:match(pattern) then
      return
    end
  end

  -- Pass through everything else
  notify_original(msg, level, opts)
end
