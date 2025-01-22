@tool
extends RichTextLabel


const PARAM_TEXT_COLOR := "cdbff0"
const PARAM_BG_COLOR := "bfbfbf1a"
const CODE_TEXT_COLOR := "da8a95"
const CODE_BG_COLOR := "8080801a"

const GAEA_MATERIAL_HINT := "Resource used to tell GaeaRenderers what to place."


func set_description_text(new_text: String) -> void:
	new_text = new_text.replace("[param]", "[color=%s][bgcolor=%s]" % [PARAM_TEXT_COLOR, PARAM_BG_COLOR])
	new_text = new_text.replace("GaeaMaterial", "[hint=%s]GaeaMaterial[/hint]" % GAEA_MATERIAL_HINT)
	new_text = new_text.replace("[code]", "[color=%s][bgcolor=%s]" % [CODE_TEXT_COLOR, CODE_BG_COLOR])

	new_text = new_text.replace("[/c]", "[/color]")
	new_text = new_text.replace("[/bg]", "[/bgcolor]")

	set_text(new_text)
