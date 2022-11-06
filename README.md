# qr-marshaljob
This is a conversion of QR-Policejob

# To Install
1. Add `qr-marshaljob` to your `[framework]` folder or whatever folder contains all of your QR resources
2. Open `qr-core` folder then open the `shared` folder
3. Edit `jobs.lua` and add the following code below

```
['marshal'] = {
    label = 'Marshals Office',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        ['0'] = {
            name = 'Deputy Marshal',
            payment = 35
        },
        ['1'] = {
            name = 'Lieutenant Marshal',
            isboss = true,
            payment = 50
        },
        ['2'] = {
            name = 'Marshal',
            isboss = true,
            payment = 150
        },
    },
},
```

5. Save the edited `jobs.lua` 
6. Restart your server!
