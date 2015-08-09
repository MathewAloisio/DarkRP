# Skills Documentation #


## PLAYER meta functions ##


* PLAYER:CanLevel(skill) **[SERVER]**
```
    *returns true if 'self.Level[skill] < skillTbl[skill].maxLevel', returns false if they have reached the max-level for 'skill'.
```
* PLAYER:LevelUp(skill) **[SERVER]**
```
	*raises 'self.Level[skill]' by 1, resets 'self.Exp[skill]' to 0.
```
* PLAYER:SetLevel(skill, val) **[SERVER]**
```
    *sets 'self.Level[skill] = val'.
```
* PLAYER:GetLevel(skill) **[SHARED]**
```
    *returns self.Level[skill](SERVER) or Level[skill](CLIENT).
```
* PLAYER:AddExp(skill, val) **[SERVER]**
```
    *sets 'self.Exp[skill] = self.Exp[skill] + val', levels the player up if they should level from the XP gain.
```
* PLAYER:SetExp(skill, val) **[SERVER]**
```
    *sets 'self.Exp[skill] = val'.
```
* PLAYER:GetExp(skill) **[SHARED]**
```
    *returns self.Exp[skill](SERVER) or Exp[skill](CLIENT).
```

## Serverside Player Variables: ##
* **player.Level** *[type: table]*
* **player.Exp** *[type: table]*

## Clientside Player Variables: ##
* **Level** *[type: table]* *[local to cl_skills.lua]*
* **Exp** *[type: float]* *[local to cl_skills.lua]*