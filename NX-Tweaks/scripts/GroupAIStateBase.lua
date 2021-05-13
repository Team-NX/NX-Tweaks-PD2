-- civilians_distinguish_detection
-- civilians_display_intimidation

local _upd_criminal_suspicion_progress_original = GroupAIStateBase._upd_criminal_suspicion_progress

function GroupAIStateBase:_upd_criminal_suspicion_progress(...)
	if self._ai_enabled then
		for obs_key, obs_susp_data in pairs(self._suspicion_hud_data or {}) do
			local unit = obs_susp_data.u_observer
			
			if managers.enemy:is_civilian(unit) then
				local waypoint_id = "susp1" .. tostring(obs_key)
				local waypoint = managers.hud and managers.hud._hud.waypoints[waypoint_id]
				
				if waypoint then
					local color, arrow_color
					
					if unit:anim_data().drop and NX.settings.civilians_display_intimidation then
						if not obs_susp_data._subdued_civ then
							obs_susp_data._alerted_civ = nil
							obs_susp_data._subdued_civ = true
							color = Color(0, 0.71, 1)
							arrow_color = Color(0, 0.35, 0.5)
							waypoint.bitmap:set_image("guis/textures/menu_tickbox")
							waypoint.bitmap:set_texture_rect(24, 0, 24, 24)
						end
					elseif obs_susp_data.alerted and NX.settings.civilians_distinguish_detection then
						if not obs_susp_data._alerted_civ then
							obs_susp_data._subdued_civ = nil
							obs_susp_data._alerted_civ = true
							
							color = Color(1, 0.5, 0)
							arrow_color = Color(0.5, 0.25, 0)
							waypoint.bitmap:set_image("guis/textures/menu_tickbox")
							waypoint.bitmap:set_texture_rect(0, 0, 24, 24)
						end
					end
					
					if color and arrow_color then
						waypoint.bitmap:set_color(color)
						waypoint.arrow:set_color(arrow_color:with_alpha(0.75))
					end
				end
			end
		end
	end
	
	return _upd_criminal_suspicion_progress_original(self, ...)
end
