th.git = th.git or {}
th.git.modified_sign = "M"
th.git.added_sign = "A"
th.git.untracked_sign = "?"
th.git.ignored_sign = "I"
th.git.deleted_sign = "D"
th.git.updated_sign = "+"
th.git.clean_sign = "-"

require("git"):setup {
	-- Order of status signs showing in the linemode
	order = 1500,
}

if os.getenv("HELIX") then
	require("toggle-pane"):entry("min-parent")
end

Status:children_add(function(self)
	local h = self._current.hovered
	if h and h.link_to then
		return " -> " .. tostring(h.link_to)
	else
		return ""
	end
end, 3300, Status.LEFT)
