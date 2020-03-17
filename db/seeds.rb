# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

Language.create({ name: 'English', alpha2: 'en' })
Language.create({ name: 'German', alpha2: 'de' })
Language.create({ name: 'French', alpha2: 'fr' })
Language.create({ name: 'Italian', alpha2: 'it' })
Language.create({ name: 'Russian', alpha2: 'ru' })
Language.create({ name: 'Spanish', alpha2: 'es' })

Page.create({ slug: 'about', name: 'What is Open Plaques?', body: 'Open Plaques is a community-based project which catalogues, curates, and promotes commemorative plaques and historical markers (often blue and round) installed on buildings and landmarks throughout the world.' })
Page.create({ slug: 'contribute', name: 'How can you help?', body: 'Open Plaques is a community-run website containing information about historical plaques found all around the world by people like you. We don\'t own it, we believe that our role is to curate it and then give the data back to the world for free. We are the museum of the street.' })
Page.create({ slug: 'data', name: 'Who can use the data and how?', body: 'anyone can, it is free!' })

Country.create({ alpha2: 'us', name: 'United States' })
uk = Country.create({ alpha2: 'gb', name: 'United Kingdom' })
Country.create({ alpha2: 'de', name: 'Germany' })
Country.create({ alpha2: 'fr', name: 'France' })
Country.create({ alpha2: 'it', name: 'Italy' })
Country.create({ alpha2: 'ca', name: 'Canada' })
Country.create({ alpha2: 'ie', name: 'Ireland' })
Country.create({ alpha2: 'ru', name: 'Russia' })
Country.create({ alpha2: 'au', name: 'Australia' })
Country.create({ alpha2: 'za', name: 'South Africa' })

Area.create({ name: 'London', country: uk })
Area.create({ name: 'Oxford', country: uk })
