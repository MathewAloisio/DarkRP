### PLAYER:DonateDaysLeft() **[SHARED]**

```
    *returns the days left in the specified players donor subscription.
```


### PLAYER:SetDonate(rank) **[SERVER]**

```
    *sets the players donate rank to 'rank', automatically adds time-left if they're already a donor.
	 If they aren't a donor already it gives them 30 days of subscription.
```


### PLAYER:IsDonate(rank) **[SHARED]**

```
    *returns true if 'self.Donate >= rank', false if it isn't.
```


### PLAYER:GetDonate **[SHARED]**

```
    *returns 'self.Donate'.
```

**NOTE:** *Use 'donate.' instead of the meta-prefix when calling "Shared" or "Clientside" functions in a clientside environment. Example: 'donate.IsDonate(rank)' instead of 'PLAYER:IsDonate(rank)'.*

## Serverside Player Variables: ##
* **player.Donate** *[type: double]* *[usage: PLAYER:GetDonate()]*
* **player.DonateTime** *[type: double]*
* **player.DonateExpire** *[type: double]*

## Clientside Player Variables: ##
* **Donate** *[type: double]* *[local to cl_donate.lua]* *[usage: donate.GetDonate() and donate.IsDonate(rank)]*
* **DaysLeft** *[type: double]* *[local to cl_donate.lua]* *[usage: donate.DonateDaysLeft()]*