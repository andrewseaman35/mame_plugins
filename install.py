import os
from pathlib import Path
import shutil

required_data_files = [
    "aws_highscore_api.log",
    "aws_highscore_init.log",
    "temp_hiscore.out",
]


def lets_do_it(prompt, default=None):
    lets_go = input(prompt) or default
    return lets_go.lower() in {"y", "yes", "aw yeah", "yee"}


plugin_name = "aws_highscore"

home = str(Path.home())
launchbox_dir = os.path.join(
    Path.home(), "Launchbox", "Emulators", "MAME_0228", "plugins"
)

plugin_dir = os.path.join(os.path.dirname(__name__), plugin_name)
installed_plugin_dir = os.path.join(launchbox_dir, plugin_name)

saved_aws_config_file_lines = None
aws_config_file = os.path.join(installed_plugin_dir, ".aws_config")
if os.path.exists(aws_config_file):
    if lets_do_it(f"Existing config file found, keep it? [y] ", "y"):
        with open(aws_config_file, "r") as f:
            saved_aws_config_file_lines = f.readlines()

if not lets_do_it(
    f"This will overwrite the contents of {installed_plugin_dir}. Continue? [y] ", "y"
):
    print("User aborted")
    exit()

shutil.rmtree(installed_plugin_dir)

shutil.copytree(plugin_dir, installed_plugin_dir)
print(f"Copied {plugin_dir} to {installed_plugin_dir}")

if saved_aws_config_file_lines:
    with open(aws_config_file, "w") as f:
        for line in saved_aws_config_file_lines:
            f.write(line)
    print("Transitioned existing AWS config file")
else:
    aws_access_key_id = input(f"AWS Access Key Id: ")
    aws_secret_key = input(f"AWS Secret Key: ")

    with open(aws_config_file, "w") as f:
        f.write(f"aws_access_key_id={aws_access_key_id}\n")
        f.write(f"aws_secret_key={aws_secret_key}")

data_dir = os.path.join(installed_plugin_dir, "data")
os.makedirs(data_dir, exist_ok=True)
for data_file in required_data_files:
    Path(os.path.join(data_dir, data_file)).touch()
