# Force of Greed Respository

This repository holds all necesssary files and assets for the current build of our game. Some of the details below outline specific fields such as workflow and useful resources for development. Note: Please use VSCode for the best experience.

## Setup
Below is the generic steps to setup your workspace. This is only done once.

1. Clone the repo.
2. Run ``rokit init`` in your terminal (I'm unsure if you have to do this, please do so anyways and report back to me (Imran))
3. Check the ``rokit.toml`` file and add the modules found in the ``[tools]`` section via ``rokit add``. (I.e ``rokit add rojo-rbx/rojo@7.6.1``)
4. You should be good to go :) Check the workflow section below.

## Workflow
This is a fully managed rojo project. Meaning the actual place file is not committed to the repository. Instead, all of the assets (Models, terrain, UI etc), and source code is stored on the git codebase instead. You can call rojo build to build an entirely new place file, with the assets saved in the git injected into the new placefile. Here's the generic workflow.

1. Run the ``build.bat`` script found in root.This should build an entirely new place file in the root of the project. (gitignore is already set up to ignore the .rbxl file). Roblox studio should open automatically.
2. Run ``rojo serve`` in your terminal. Then sync in Roblox Studio
3. Do your work. Change assets, add new assets, write new code etc.
4. At the end of your development session, Save to File using the File option in the top right of your roblox studio.
5. Run the ``pull.bat`` script. THIS IS A MUST
6. Commit and Push to your branch
7. If your feature is done, open a PR to the main branch.

## How Asset Saving Works
Check and understand the ``pullTemplate.luau`` script found in scripts folder in root. Your roblox studio directory consists of top level folders called services (i.e Workspace, Lighting, ServerStorage are services). Due to issues that I have no idea how to fix, you can only save assets within services, not the service itself. For the most part, this shouldn't affect you, unless you need to add a new folder underneath service.

For example, our workspace service currently has a folder named assets, which i have already set to be pulled with the script. Preferably, any new assets (or folders containing assets) go under this folder. However, if you'd like to add a new folder (perhaps a folder named Settings) in Workspace, you'll have to do extra actions.

1. Add the folder you'd like to pull in the pull.luau script. Your line of code should like this

``fs.writeFile("./src/assets/service/asset.rbxm", roblox.serializeModel({game.service.asset}))``

Make sure the path you're writing to exists.

2. Add the path that you've set (First field of the fs.writeFile argument) to the ``default.project.json`` file. Follow the structure.

``"serviceName": {
    "$path": "path to your service folder"
}``

## How Github Project works
You should notice that attached to this repository (in the Github Website) is a project section. All our tasks are managed there, where we assign each other tasks. The general workflow goes like this.

1. Assign a new task (feature implementation or bugfix)
2. Create a new branch for your task.
3. Work on that branch until it is done.
4. Once your task is ready for implementation, open a pull request (PR) where other members can review your code together with you
5. If all goes smoothly, your branch is merged to main.

## Rules and Design Philosophies
Here's a couple things to note down while you are working.

1. When saving assets, only extract the assets you have modified and touched (and is the asset you want to merge into the main branch); i.e leave the files that you haven't touched unchanged. The best way to do practice this is...
2. Always save files individually from your studio. Instead of extracting and saving a folder (such as Workspace.Assets), save the files that are inside the folder as individual .rbxm files instead. While being more tedious (see some helpful resources below), it helps as it leads to less and less merge conflicts down the road.
3. The `pullTemplate.luau` script found in the scripts folder is only a template. Please copy over to your own pull script, and rename it to `pull.luau` (I've configured so it's already in the .gitignore). This is so you have your own script to play with (since we're not all saving the same assets)
4. Here are some naming conventions to follow (for directories)

| Type                | Naming Convention                                      |
| ------------------- | ------------------------------------------------------ |
| File                | [camelCase](https://en.wikipedia.org/wiki/Camel_case)  |
| Folder              | PascalCase                                             |
| Service (In Studio) | PascalCase                                             |
| Service (In VSCode) | [snake_case](https://en.wikipedia.org/wiki/Snake_case) |
|                     |                                                        |

Some helpful approaches and resources to make saving and extracting less tedious

1. If you're confident in scripting, you can modify your own script to make input easier.
2. Use a macro to save and re-type common directories (like Workspace.Assets.UI.)
3. While initially hard to remember to do, make sure to instantly add directories you've changed, removed, or added to a notepad or txt file so you can remember which assets you'll need to save and extract at the end of your work session

