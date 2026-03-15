class GameScript {
  // --- General ---
  static const String cityName = 'Mavenport';
  static const String agencyFullName = 'Mavenport Counter-Terrorist Agency';
  static const String agencyAbbrev = 'MCTA';
  static const String terroristsFullName = 'Mavenport Underground Thug Outfit';
  static const String terroristsAbbrev = 'MUTO';
  static const List<String> districtNames = [
    'Barracks',
    'Inner Maven',
    'Mavenport Gardens',
    'Northern Heights',
    'Outer Maven',
    'South-East Central',
  ];

  // --- Standins ---
  static const String districtStandin = '[DISTRICT]';
  static const String firstNameStandin = '[FIRST NAME]';
  static const String lastNameStandin = '[LAST NAME]';
  static const String ageStandin = '[AGE]';

  // --- Residents ---
  static const List<String> maleFirstNames = [
    'Adam',
    'Christopher',
    'Daniel',
    'Eddy',
    'James',
    'Jonathan',
    'Kingsley',
    'Nikita',
    'Peter',
    'Richard',
    'Robert',
    'Samuel',
    'Shawn',
    'Steven',
    'Tristan',
    'Vincent',
    'Winston',
  ];
  static const List<String> femaleFirstNames = [
    'Alberta',
    'Anne',
    'Avery',
    'Barbara',
    'Carrie',
    'Dorothy',
    'Elisabeth',
    'Emma',
    'Eva',
    'Jill',
    'Joan',
    'Martha',
    'Mary',
    'Monica',
    'Peggy',
    'Ruth',
    'Susan',
  ];
  static const List<String> lastNames = [
    'Adams',
    'Brown',
    'Burnett',
    'Carter',
    'Churchill',
    'Collins',
    'Davis',
    'Fisher',
    'Grant',
    'Harding',
    'Higgins',
    'Jackson',
    'Johnson',
    'Mathers',
    'Miller',
    'Nelson',
    'Price',
    'Smith',
    'Stewart',
    'Thompson',
    'Wilcox',
    'Williams',
    'Wilshire',
    'Wilson',
  ];
  static const Map<String, List<String>> streetNames = {
    'Barracks': ['Browning St'],
    'Inner Maven': ['Glass Rd'],
    'Mavenport Gardens': ['Daisy Ln'],
    'Northern Heights': ['Wuthering St', 'Rebecca Ave'],
    'Outer Maven': ['Pivot Dr'],
    'South-East Central': ['Maven Blvd'],
  };
  static const List<String> occupations = [
    'artist',
    'clerk',
    'doctor',
    'factory worker',
    'lawyer',
    'mechanic',
    'office worker',
    'student',
    'teacher',
    'unemployed',
  ];

  // --- Exposition ---
  static const String expositionFirstPart = '''
The corner store on Wuthering St is closed today.

The bars installed on the windows did nothing to stop looters from shattering the glass. The metal frames lay like carcasses on the ground. Cardboard and wood pallets board up the openings, dirty and uninviting. One pallet hangs crooked revealing an empty store. There’s nothing left for anyone. "MUTO" is spraypainted on the storefront in bright red. 

The cameras in the area pause at the graffiti during every pass. Their mechanical eyes rove around, trying to catch any clues on the terrorists. Though their lenses captured the act, the perpetrators disappeared before the authorities reached the scene. 

The wind howls, but otherwise the neighborhood is quiet. All lights are off. People stay indoors with their curtains shut. They’ve tucked themselves away from the world outside. They whisper amongst themselves: about the state of the streets, about the curfew, and about what’s going to happen in the morning. One word is echoed in their whispers over and over: "MUTO" ...
	''';

  static const String expositionSecondPart = '''
MUTO, or the Mavenport Underground Thug Outfit, has become a powerful criminal organization in the city of Mavenport. Nobody can pinpoint the exact moment the group came into existence. At first their operations were interpreted as accidents rather than a series of planned out attacks to terrorize the city.
	
One of the first incidents to raise suspicion was a hit-and-run in the Barracks – a beloved community leader was found dead in the streets. The Barracks, home to many of Mavenport’s factories and plants, hosts a close-knit community of workers, who all mourned the loss.

Next came a shooting at Mavenport University. Northern Heights, where the university is located, has been the site of frequent protests ever since.

Mavenport Gardens holds the largest park in the city. What used to be the most popular district to raise a family and a prime location for sports games, festivals, and picnics, has now become a hotspot for drug deals and muggings.

Inner Maven lies in the heart of Mavenport, the home of the Civic Center, Police Grand Station, and the Mavenport Hospital. The glittering buildings used to be kept shiny and new – now they are worn down and grimy, with shady establishments inside them.

South-East Central still has a reputation for the finer things in life - it's home to those who appreciate high end shopping, art galleries, and fine dining. However, its high-style has made the area a target of frequent robberies.

As the largest district, Outer Maven has it all – homes, restaurants, businesses, schools, clubs, community centers.... What used to be a bustling and busy area, is now home to most of the crimes in Mavenport.

Little is known about the organization identified as the root cause of Mavenport's decline. To find out more about their internal structures, and to deal with the situation effectively, the Mavenport Counter-Terrorist Agency (MCTA) has been established....
	''';

  // --- Intel reports ---
  static const String intelBriefing = '''
This is your briefing for the SMSAIAAASS – the "System for Monitoring Suspicious Activity and Initiating Appropriate Action Against Suitable Suspects."
	''';

  // These will raise the risk of residents within a certain district.
  static const List<String> districtInstructions = [
    'Nightly traffic has increased in [DISTRICT]. Increased surveillance to that area may be necessary.',
    'Cameras in [DISTRICT] have been taken out. Officers have been deployed to restore surveillance.',
    'Camera in [DISTRICT] has been vandalized.',
    'Cables for a camera in [DISTRICT] have been cut. An electrician has been requested to fix the issue.',
    'Homeless population increased in [DISTRICT] due to new laws passed regarding the city bridge.',
    'Noise complaints during early mornings and after sunset in [DISTRICT].',
    'Undisclosed assembly occurring in [DISTRICT].',
    'Noted rise in complaints from residents in [DISTRICT], mentioning a foul odor.',
    'Officers found a box of tampered passports in [DISTRICT].',
    'Power outage in [DISTRICT] due to cut wire.',
    'Suspicious persons reported in [DISTRICT].',
    'An explosion was reported in [DISTRICT].',
    'Hotline has reported more foot traffic coming from [DISTRICT] at 2am.',
    'Hotline has reported an increased number of gatherings in [DISTRICT].',
  ];

  // These will raise the risk of residents with a certain occupation.
  static const Map<String, List<String>> occupationInstructions = {
    'artist': [
      'Mural artists paint mysterious symbols in addition to their signature on the side of the building.',
    ],
    'clerk': ['Clerks organize secret meetings throughout the districts.'],
    'doctor': [
      'Mysterious flyers are being passed out in the work lounge at the hospital.',
    ],
    'lawyer': [
      'Lawyers with popular firms are making suspicious amounts of money.',
    ],
    'mechanic': ['An increase in cash is being exchanged at mechanic shops.'],
    'office worker': [
      'Office workers from different offices are congregating together in an unknown pattern during lunch.',
    ],
    'student': ['An unidentified group of students has been linked to MUTO.'],
    'teacher': [
      'Undercover agents found suspicious documents in the Teacher’s association head office.',
      'Tenured professors are holding private seminars for students outside of classes.',
    ],
  };

  // These will raise the risk of residents in a certain age group.
  static const Map<String, List<String>> demographicsInstructions = {
    '18-29': [
      'Agents to investigate new stylized “M” decal, popular amongst young residents.',
    ],
    '30-39': ['Suspect of a hit-and-run rumored to be male, in his mid 30’s.'],
    '40-64': [
      'Analysis by the statistical department revealed a high correlation between 40-64 year olds and MUTO membership.',
    ],
    '65+': ['Seniors have been acting hella sus recently.'],
  };

  // These won't raise the risk.
  static const List<String> risklessInstructions = [
    'Conference for new medical technology and hospital care being held in [DISTRICT].',
    'Moms hosting baby clothes swap with the community in [DISTRICT].',
    'Weekly dog walking group meets on Thursdays in a route in [DISTRICT].',
    'Animal charity readies itself for quarterly fundraisers. Next one will take place in [DISTRICT].',
    'Church undergoing renovation in [DISTRICT]. Local artists to paint murals in the mornings.',
    '[DISTRICT] has seen an increased number of ticket fines after camera installation at stoplights.',
    'Flea market scheduled for the morning in [DISTRICT].',
    'Students have been congregating in protests in local parks in [DISTRICT].',
    'Office building in [DISTRICT] currently undergoing construction.',
    'Unemployment office has been overbooked for appointments despite low unemployment rates in the city.',
    'Hotline has reported an increase in foreigners to the area.',
    'Mystery QR code flyers have been posted onto the bulletin boards at city hall.',
    'Suspect of a recent cat burglary, must be petite, can fit through a side window.',
    'Suspects of a recent robbery in [DISTRICT], thought to be from a different district due to unfamiliarity when leaving the store.',
  ];

  // --- News bulletins ---
  // These are tricky: if we have the time, the resident names should be made to fit the message, so that when it says teacher, the name actually belongs to a teacher in the resident database. For now let's just pick anyone from the database for each message. Also show only 5 or 6 of these in one playthrough.
  static const Map<int, List<String>> newsBulletins = {
    1: [
      'Local officials state that crime is on the rise. Residents should act with caution within their neighborhood and report suspicious activity.',
      'Electricity bills soar during this season. MUTO to blame?',
      'Community leader [FIRST NAME] [LAST NAME] wins award from neighborhood association.',
      'Bill passed to increase fines on desecrating public property. Graffiti artists beware!',
      'More surveillance cameras installed in [DISTRICT]. Authorities say this will reduce speeding in busy intersections.',
      'The city park in Mavenport Gardens to shorten opening hours due to a wave of de-funding.',
      'Annual Mavenport police ball to be held next Saturday evening. "The food is going to blow your hats off!", says caterer.',
      '[FIRST NAME] [LAST NAME], [AGE], from [DISTRICT] wins big in lottery.',
      'Loitering to be banned in [DISTRICT].',
      'Mavenport farmer’s market continues for the 15th year despite decrease in attendance.',
      'Noise ordinance laws go into effect on Monday. More information on the city website.',
      'Brimmed hats, and waistcoats are now in vogue! "Everybody\'s buying them! I\'ve never seen anything like it", says owner of a local fashion outlet.',
    ],
    2: [
      'University student [FIRST NAME] [LAST NAME] loses scholarship over MUTO accusation: “I’m an eco-terrorist, not a terrorist-terrorist!”',
      'Real estate market boom continues - so does real estate fraud. Information on how to not get screwed over on the city website.',
      'Riot takes place outside of a football tournament in [DISTRICT]. Officers deployed to restore order.',
      'Volunteer association holds fundraisers for children’s sports programs in the city.',
      'Student assessment program reveals state of education. Local school representative [LAST NAME] says that: “There\'s room for improvement.... Much, much room for improvement.”',
      'Police uniforms to receive a design overhaul. "It was about time!", says prominent fashion guru.',
      'MUTO hotline, now hiring. No prior work experience or education necessary. Must be eighteen and older and have no priors to apply.',
      'Heatwaves could bring record breaking temperatures to the region.',
      'Shooting at a chicken fast food restaurant, scares the neighborhood. Was MUTO involved?',
      'Students protest over new restrictions placed on campus.',
      'Survey reveals [DISTRICT] is the safest place to vacation this season. Check out the best attractions on the city website.',
      'Neighborhood Association reaches out for community feedback. “We want to serve the people.”',
    ],
    3: [
      '[FIRST NAME] [LAST NAME], man accused of being a part of MUTO claims his innocence: "No, wait, I am innocent! Please don\'t take me away. I am a single dad and I have four children at home! Who\'s going to look after my children?!"',
      'Pest control called for local church. Members hold service in the community center in [DISTRICT].',
      'Annual cook-out hosted in [DISTRICT] in September. Read new rules for participation on the city website.',
      'New surveillance system causes a surge of ticket fines. Local courthouses are booked.',
      'Approval of government officials goes down due to embezzlement rumours.',
      'Official Mavenport social media account has been created. Tag us in your photos. #MAVENPORTROCKS',
      'Temple soup kitchen provides nutritious and vegetarian meals for the community.',
      'HVAC units all over the city stop working as electrical grid works overtime.',
      '[DISTRICT] Boys and Girls basketball teams win championship. Residents will cheer them on as they move on to regionals.',
      'Restoration of [DISTRICT] theater paused after MUTO threat made against community chairman.',
      '10th grader [FIRST NAME] [LAST NAME] wins regional science fair. Congratulations!',
      'Residents complain of rising phone and internet bills. Could fiber cable be the answer?',
      '3 suspects arrested in connection with supermarket stealing spree. 25 more on the run. Residents are urged to call in tips under 00-88-9999.',
      'Hospital cracks down on patient policies. “No devices within certain areas of the hospital! It\'s for patient safety!”',
      'University breaks out the scantron machine. “Not everything needs to be done over the computer,” says one professor.',
      'Brawl breaks out in [DISTRICT] grocery store as shoppers accuse each other of being members of MUTO. More than a dozen people were hurt during the altercation.',
    ],
    4: [
      'Large groups of people are a hazard to walking safely on sidewalks. Groups larger than four people are asked to disperse.',
      'This month is movement month! Make sure to include a walk in your daily schedule!',
      'Dog walkers are reminded to clean up after their pets. Fines will be distributed for vandalization of public property.',
      'Local sanitation worker [FIRST NAME] [LAST NAME], shot by off-duty government official. Government agency has declined to comment.',
      '[DISTRICT] Chef makes signature dish for the city: “I want to show off what I love about this place.”',
      'Factory workers demand better working conditions in rising heat.',
      'Fire fighters remind residents to take fire safety ordinances seriously.',
      'Blue Collar workers holding Job Fair in [DISTRICT]. Organisers express safety concerns.',
      'Local couple sues hospital in harassment claims due to withheld care.',
      '“MUTO to blame!”, says Sen. [FIRST NAME] [LAST NAME] when asked about rising rents in the city.',
      '[DISTRICT] demolishes local playground. “The safety code wasn’t up to standard”, says local official.',
      'One killed and three injured in [DISTRICT] shooting.',
      'District Attorney [LAST NAME] pleads guilty to worker’s compensation fraud case.',
      'City sees a decrease in reservations to community centers. “No one wants to be outside right now!”, says a local park goer.',
      'Sold out! Curtains are all the rage this season! Read about the new trend on our city website.',
      'Local government clerk in the courthouse is taken away for questioning. Operations grind to a halt.',
      'Neighborhood Association writes letters to the mayor regarding ineffectual government policies.',
      'The government would like to remind Mavenport that the MUTO hotline is for legitimate concerns only. Not for petty grievances about parking tickets and PTA drama! >:(',
      'Services in Mavenport slow as residents leave their jobs. "It\'s almost as though vacation season came early this year!"',
      'Local student begs the community to search for their father. "He went to the store to buy milk and never returned!”',
    ],
    5: [
      '19:00 curfew in effect. Only mandatory workers should be out from 10pm to 5am, and must show identification to continue to their occupations. Officers have been deployed to provide protection and escort to those in need of travel.',
      'Meet our cute new police dogs on the city website!',
      'Mavenport restaurants closed by health inspectors this week. Visit the city website for more information.',
      'Gun violence cases surge in [DISTRICT]. Police Chief says, “MUTO is our primary suspect in the rising trend. Rest assured: we are investigating.”',
      'Healthcare officials say ERs are "flooded with patients" after wave of salmon poisoning cases. "It could be salmonella, but there\'s definitely something fishy going on!"',
      'Certifications for electricians now on the rise.',
      'Oldest cat in the city celebrates 17th birthday. See the photos on the city website.',
      'Certain areas of the community will be closed down for repairs.',
      'Librarian [FIRST NAME] [LAST NAME] welcomes all to the [DISTRICT] public library. “Nothing a good book can’t solve!”',
      'New coffee machine installed in city hall. “Come enjoy a cup with us!”',
      'Deadly fire injures dozens and kills two in [DISTRICT]. Griefing residents call for thorough investigation.',
      'New class "The Art of Letter Writing" being offered in the community college.',
      'Little League cancelled! Not enough sign-ups for the season.',
      'Face masks and sunglasses banned in public spaces. "Only people who have something to hide wear them", says officer [LAST NAME] of the Mavenport Police Department.',
      'Employee walk-out! Office workers refuse to come back to work after executive jokes about tapping company lines.',
      'Students protest at city hall! They want something done about what’s happening to the city.',
      'Mavenport Farmer’s Market sees reduction in size! Less vendors and customers than ever!',
      'Officers everywhere! Off-duty officers make an unprecedented number of arrests in Mavenport!',
    ],
  };

  // --- Epilogue ---
  static const String epilogueNewspaperName = 'The Mavenport Times';
  static const String epilogueNewspaperHeading =
      'Scandal! MCTA spies on Mavenport residents';
  static const String epilogueNewspaperArticle = '''
Mavenport residents were shocked when they found out Mavenport officials had embezzled government funds to create an unauthorized watch-force in the city.

This watch-force, known to many as the MCTA, was founded under mysterious circumstances after an unfortunate crime wave. After one incident, the letters MUTO were found above a victim’s corpse. Afterwards, rumors began circulating that a violent criminal organization - the Mavenport Underground Thug Outfit was growing within Mavenport’s borders.

However, recent investigations revealed that the level of crime remained at a stable level and that MUTO was in fact entirely fabricated by the MCTA. Internal documents leaked by MCTA employees revealed that MUTO was in reality devised as "Made-Up Terrorist Organisation" and used to create a panick among the Mavenport population. This panick served as justification for developing the SMSAIAAASS, a sophisticated surveillance system surveilling Mavenport residents without their knowledge. Hundreds of innocent residents were detained for questioning over the last 12 months alone.

Thankfully, an enterprising group of electricians and other blue collar workers reported irregularities with Mavenport’s electric grid. Authorities traced the issue to the MCTA, and the Senate has voted unanimously to defund the agency and to destroy the SMSAIAAASS. All innocent individuals were released and were offered psychological counsel for their experiences.
	''';

  static const String epilogueBriefingHeading =
      'Emergency notice from the MCTA.';
  static const String epilogueBriefingText = '''
All intranet communication has been transferred to port 2576.

Informants have been neutralised.

Refer to the MCTA as the Mavenport Security Bureau (MSB) henceforth.

Continue with your duties as usual.

The SMSAIAAASS will prevail.

The MCTA will prevail.

MUTO will prevail.

Our security depends on it.
	''';
}
