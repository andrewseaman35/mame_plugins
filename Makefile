PLUGIN_DIRECTORY=/usr/share/games/mame/plugins/

update_local:
	sudo rm -rf  /usr/share/games/mame/plugins/aws_highscore
	sudo cp -r ./aws_highscore $(PLUGIN_DIRECTORY)


.PHONY: copy_local