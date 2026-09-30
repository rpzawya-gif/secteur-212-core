Core = Core or {}
Core.Shared = Core.Shared or {}

-- [[ NATIVE JOBS CONFIGURATION ]]
-- Master Directive v2.0 Compliant
-- This table is natively accessed by ag_core and acts as the central source of truth for all jobs, grades, and paychecks.

Core.Shared.Jobs = {
    ['unemployed'] = {
        label = 'Unemployed',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = {
                name = 'Freelancer',
                payment = 15
            }
        }
    },
    ['police'] = {
        label = 'Los Santos Police Department',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = {
                name = 'Recruit',
                payment = 50
            },
            ['1'] = {
                name = 'Officer',
                payment = 75
            },
            ['2'] = {
                name = 'Sergeant',
                payment = 100
            },
            ['3'] = {
                name = 'Lieutenant',
                payment = 125
            },
            ['4'] = {
                name = 'Chief of Police',
                payment = 150,
                isboss = true
            }
        }
    },
    ['ambulance'] = {
        label = 'Emergency Medical Services',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = {
                name = 'EMT Trainee',
                payment = 50
            },
            ['1'] = {
                name = 'Paramedic',
                payment = 75
            },
            ['2'] = {
                name = 'Doctor',
                payment = 100
            },
            ['3'] = {
                name = 'Chief Medical Officer',
                payment = 140,
                isboss = true
            }
        }
    },
    ['mechanic'] = {
        label = 'Los Santos Customs',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            ['0'] = {
                name = 'Trainee',
                payment = 40
            },
            ['1'] = {
                name = 'Mechanic',
                payment = 65
            },
            ['2'] = {
                name = 'Lead Mechanic',
                payment = 90
            },
            ['3'] = {
                name = 'Manager',
                payment = 120,
                isboss = true
            }
        }
    }
}
