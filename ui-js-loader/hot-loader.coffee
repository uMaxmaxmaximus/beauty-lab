ComponentPatcher = require './component-patcher'


module.exports = class HotLoader

	@patch: (module)->
		unless module.hot then return

		if module.__esModule
			for key, target of module.exports
				module.exports[key] = @tryPatchTarget(target, module)
		else
			module.exports = @tryPatchTarget(module.exports, module)

		return


	@tryPatchTarget: (target, module)->
		if ComponentPatcher.test(target)
			target = ComponentPatcher.patch(target, module)
		return target



