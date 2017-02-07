import 'babel-polyfill'

const TYPE_MARKER = '##type##'
const VALUE_MARKER = '##value##'
const hasOwn = {}.hasOwnProperty


export default class Encoder {


	static customTypes = []


	static add(customType) {
		for (let existsCustomType of this.customTypes) {
			if (existsCustomType.type.name === customType.type.name) {
				throw Error(`Тип с именем '${customType.type.name}' уже существует`)
			}
		}
		this.customTypes.push(customType)
	}


	static toJSON(target) {
		return JSON.stringify(this.encode(target))
	}


	static fromJSON(json) {
		return this.decode(JSON.parse(json))
	}


	static encode(target, buffer = new Map) {
		if (target !== Object(target)) return target

		if (buffer.has(target)) {
			return buffer.get(target)
		}

		for (let customType of this.customTypes) {
			if (target instanceof customType.type) {
				return {
					[TYPE_MARKER]: customType.type.name,
					[VALUE_MARKER]: this.encode(customType.encode(target)),
				}
			}
		}

		if (target.toJSON) {
			target = target.toJSON()
		}

		var wrapper = Array.isArray(target) ? [] : {}
		buffer.set(target, wrapper)
		for (let key in target) if (hasOwn.call(target, key)) {
			wrapper[key] = this.encode(target[key], buffer)
		}

		return wrapper
	}


	static decode(target) {
		if (target !== Object(target)) return target

		if (target[TYPE_MARKER]) {
			for (let customType of this.customTypes) {
				if (target[TYPE_MARKER] === customType.type.name) {
					return this.decode(customType.decode(target[VALUE_MARKER]))
				}
			}
		}

		for (let key in target) if (hasOwn.call(target, key)) {
			target[key] = this.decode(target[key])
		}

		return target
	}

}


Encoder.add({
	type: Date,
	encode: value => value.getTime(),
	decode: value => new Date(value),
})


Encoder.add({
	type: Set,
	encode: value => Array.from(value),
	decode: value => new Set(value),
})


Encoder.add({
	type: RegExp,
	encode: value => [value.source, value.flags],
	decode: value => new RegExp(...value),
})


// if (target instanceof Blob) {
// 	stream = ss.createStream()
// 	ss.createBlobReadStream(target).pipe(stream)
// 	return stream
// }

