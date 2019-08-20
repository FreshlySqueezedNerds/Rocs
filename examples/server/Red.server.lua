local Rocs = require(script.Parent.Rocs)

Rocs:registerComponent({
	name = "Red";
	tag = "Red";

	entityCheck = {"BasePart"};

	components = {
		Replicated = {
			players = {};
		};
	};

	defaults = {
		color = "Really red"
	};

	randomize = function(self)
		self:set("color", BrickColor.random().Name)
	end;
})
