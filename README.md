# Hitmarker
A simple plugin that displays a hitmarker in the center of the screen when hitting an enemy.<br>This [video](https://www.youtube.com/watch?v=J5h1kIwjClA) demonstrates how this plugin works.

# Installation
Installing the plugin consists of several steps:
1. [Download](https://github.com/kekekekkek/Hitmarker/archive/refs/heads/main.zip) this plugin;
2. Go to the root folder of the game (for example `C:\Program Files (x86)\Steam\steamapps\common\Sven Co-op`) and move the `svencoop` folder there;
3. If the operating system prompts you to replace the files, replace them;
4. Next, go to the `..\Sven Co-op\svencoop` folder and find there the text file `default_plugins.txt`;
5. Open this file and paste the following text into it:
```
	"plugin"
	{
		"name" "Hitmarker"
		"script" "Hitmarker"
	}
```
6. After completing the previous steps, you can run the game and check the result.

# Commands
When you start the game and connect to your server, you will have the following plugin commands at your disposal, which you will have to write in the game chat to activate them.
| Command | MinValue | MaxValue | DefValue | Description | Usage | 
| ------- | -------- | -------- | -------- | ----------- | ----- |
| `.hm`, `/hm` or `!hm` | `0` | `1` | `1` | Allows you to enable or disable this feature. (`AdminsOnly`) | Usage: `.hm or /hm or !hm <enabled>.` Example: `!hm 1` |
| `.hm_size`, `/hm_size` or `!hm_size` | `0` | `5` | `2` | Allows you to change the size of the hitmarker.<br>`0 - Disabled;`<br>`1 - Very Small;`<br>`2 - Small;`<br>`3 - Normal;`<br>`4 - Big;`<br>`5 - Very Big.` | Usage: `.hm_size or /hm_size or !hm_size <size>.` Example: `!hm_size 2` |
| `.hm_hsnd`, `/hm_hsnd` or `!hm_hsnd` | `0` | `5` | `1` | Allows you to change the sound when hitting an enemy.<br>`0 - Mute;`<br>`1 - COD;`<br>`2 - Bell;`<br>`3 - Bubble;`<br>`4 - Nya;`<br>`5 - Anime.` | Usage: `.hm_hsnd or /hm_hsnd or !hm_hsnd <sound>.` Example: `!hm_hsnd 1` |
| `.hm_ksnd`, `/hm_ksnd` or `!hm_ksnd` | `0` | `2` | `0` | Allows you to change the sound when killing an enemy.<br>`Currently not working.` | Usage: `.hm_ksnd or /hm_ksnd or !hm_ksnd <sound>.` Example: `!hm_ksnd 2` |
| `.hm_hcolor`, `/hm_hcolor` or `!hm_hcolor` | `0 0 0 0` | `255 255 255 255` | `255 255 255 125` | Allows you to change the color when hitting an enemy. | Usage: `.hm_hcolor or /hm_hcolor or !hm_hcolor <red> <green> <blue> <alpha>.` Example: `!hm_hcolor 255 255 255 125` |
| `.hm_kcolor`, `/hm_kcolor` or `!hm_kcolor` | `0 0 0 0` | `255 255 255 255` | `255 0 0 125` | Allows you to change the color when killing an enemy. | Usage: `.hm_kcolor or /hm_kcolor or !hm_kcolor <red> <green> <blue> <alpha>.` Example: `!hm_kcolor 255 0 0 125` |
| `.hm_ao`, `/hm_ao` or `!hm_ao` | `0` | `1` | `0` | Allows you to enable this feature only for admins or for all players. (`AdminsOnly`)<br>`0 - For everyone;`<br>`1 - Admins only.` | Usage: `.hm_ao or /hm_ao or !hm_ao <adminsonly>.` Example: `!hm_ao 0` |
| `.hm_reset`, `/hm_reset` or `!hm_reset` | `-` | `-` | `-` | Allows you to reset the settings to the default settings. | `No arguments.` |

**REMEMBER**: The server may freeze with a large number of players. I will try to fix this in the future.<br>
**REMEMBER**: The `killsound` folder is not in use yet. In the future, sound will be added when killing an enemy.<br>
**REMEMBER**: If you set the color of the hitmarker to black, then it simply will not be displayed on your screen.<br>
**REMEMBER**: Also, setting the `alpha channel` for the hitmarker to `0` will disable it.<br>
**REMEMBER**: You can also draw your own hitmarker sprite and replace one of the existing files.<br>

# Screenshots
* Screenshot 1<br><br>
![Screenshot_1](https://github.com/kekekekkek/Hitmarker/blob/main/Images/Screenshot_1.png)
* Screenshot 2<br><br>
![Screenshot_2](https://github.com/kekekekkek/Hitmarker/blob/main/Images/Screenshot_2.png)
* Screenshot 3<br><br>
![Screenshot_3](https://github.com/kekekekkek/Hitmarker/blob/main/Images/Screenshot_3.png)
* Screenshot 4<br><br>
![Screenshot_4](https://github.com/kekekekkek/Hitmarker/blob/main/Images/Screenshot_4.png)
