extends CanvasLayer
class_name TitleCard
@onready var rich_text_label: RichTextLabel = $Panel/RichTextLabel


func showTitleCard(title: String = "Introduction") -> void:
	visible = true
	var displayTextFinal: String = "[center][b][font_size=40]" + title +  "[/font_size][/b][/center]"
	if displayTextFinal != rich_text_label.text:
		rich_text_label.text = displayTextFinal
	
