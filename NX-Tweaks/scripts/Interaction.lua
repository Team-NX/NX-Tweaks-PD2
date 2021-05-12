if string.lower(RequiredScript) == "lib/units/interactions/interactionext" then
	local BaseInteraction_can_select_original = BaseInteractionExt.can_select
	
	function BaseInteractionExt:can_select(player)
		if NX.settings.disable_shaped_charges_during_stealth and managers.groupai:state():whisper_mode() and self._tweak_data.required_deployable and self._tweak_data.required_deployable == "trip_mine" then
			return false
		end
		
		return BaseInteraction_can_select_original(self, player)
	end
end
