-- ensuring that database is dropped before creating one
USE master;

-- Drop database
IF DB_ID('Blog') IS NOT NULL DROP DATABASE Blog;

-- If database could not be created due to open connections, abort
IF @@ERROR = 3702
   RAISERROR('Database cannot be dropped because there are still open connections.', 127, 127) WITH NOWAIT, LOG;

-- Starting assignment
CREATE DATABASE Blog;
GO

USE Blog;
GO

CREATE PROCEDURE dbo.CreateTables
AS
BEGIN

  CREATE TABLE dbo.Roles
  (
    RoleId INT NOT NULL IDENTITY,
    Name NVARCHAR(255) NOT NULL,
    CONSTRAINT PK_RoleId
      PRIMARY KEY(RoleId)
  );
  
  CREATE TABLE dbo.Users
  (
    UserId INT NOT NULL IDENTITY,
    Email NVARCHAR(255) NOT NULL,
    Name NVARCHAR(255) NOT NULL,
    [Password] NVARCHAR(64) NOT NULL,
    Created DATETIME NOT NULL DEFAULT GETDATE(),
    RoleId INT NOT NULL,
    CONSTRAINT PK_UserId
      PRIMARY KEY(UserId)
  );
  
  CREATE TABLE dbo.States
  (
    StateId INT NOT NULL IDENTITY,
    Name NVARCHAR(255) NOT NULL,
    CONSTRAINT PK_StateId
      PRIMARY KEY(StateId)
  );
  
  CREATE TABLE dbo.Posts
  (
    PostId INT NOT NULL IDENTITY,
    Title NVARCHAR(MAX) NOT NULL,
    Body NVARCHAR(MAX),
    Created DATETIME NOT NULL DEFAULT GETDATE(),
    Edited DATETIME,
    UserId INT NOT NULL,
    StateId INT,
    CONSTRAINT PK_Post
      PRIMARY KEY(PostId)
  );
  
  CREATE TABLE dbo.Categories
  (
    CategoryId INT NOT NULL IDENTITY,
    Name NVARCHAR(255) NOT NULL,
    ParentId INT,
    CONSTRAINT PK_CategoryId
      PRIMARY KEY(CategoryId)
  );
  
  CREATE TABLE dbo.PostsCategories
  (
    PostId INT NOT NULL,
    CategoryId INT NOT NULL,
    CONSTRAINT PK_PostId_CategoryId
      PRIMARY KEY (PostId,CategoryId)
  );
  
  CREATE TABLE dbo.Tags
  (
    TagId INT NOT NULL IDENTITY,
    Name NVARCHAR(255) NOT NULL,
    CONSTRAINT PK_TagId
      PRIMARY KEY(TagId)
  );
  
  CREATE TABLE dbo.PostsTags
  (
    PostId INT NOT NULL,
    TagId INT NOT NULL,
    CONSTRAINT PK_PostId_TagId
      PRIMARY KEY (PostId,TagId)
  );
  
  CREATE TABLE dbo.[Permissions]
  (
    PermissionId INT NOT NULL IDENTITY,
    Name NVARCHAR(255) NOT NULL,
    CONSTRAINT PK_PermissionId
      PRIMARY KEY(PermissionId)
  );
  
  CREATE TABLE dbo.[RolesPermissions]
  (
    RoleId INT NOT NULL,
    PermissionId INT NOT NULL,
    CONSTRAINT PK_RoleId_PermissionId
     PRIMARY KEY (RoleId, PermissionId)
  );

  CREATE TABLE dbo.Comments
  (
    CommentId INT NOT NULL IDENTITY,
    PostId INT NOT NULL,
    UserId INT NOT NULL,
    Created DATETIME NOT NULL DEFAULT GETDATE(),
    Edited DATETIME,
    Body NVARCHAR(MAX),
    ParentId INT,
    CONSTRAINT PK_CommentId
      PRIMARY KEY(CommentId)
  );

  CREATE TABLE dbo.PostLog
  (
    PostLogId INT NOT NULL IDENTITY,
    [Date] DATETIME NOT NULL DEFAULT(SYSDATETIME()),
    LoginName sysname NOT NULL DEFAULT(ORIGINAL_LOGIN()),
    [Action] CHAR(1) NOT NULL,
    PostId INT NOT NULL,
    PostTitle NVARCHAR(MAX) NOT NULL,
    CONSTRAINT PK_PostLogId
      PRIMARY KEY(PostLogId)
  );

END
GO

CREATE PROCEDURE dbo.CreateForeignKeys
AS
BEGIN
  
  ALTER TABLE dbo.Users  
    ADD
      CONSTRAINT FK_Users_Roles_RoleId
        FOREIGN KEY(RoleId)
        REFERENCES dbo.Roles(RoleId);
  
  ALTER TABLE dbo.Posts
    ADD
      CONSTRAINT FK_Posts_Users_UserId
        FOREIGN KEY(UserId)
        REFERENCES dbo.Users(UserId),
      CONSTRAINT FK_Posts_States_StateId
        FOREIGN KEY(StateId)
        REFERENCES dbo.States(StateId);
  
  ALTER TABLE dbo.Categories
    ADD
      CONSTRAINT FK_ParentId_CategoryId
        FOREIGN KEY(ParentId)
        REFERENCES dbo.Categories(CategoryId);
  
  ALTER TABLE dbo.PostsCategories
    ADD
      CONSTRAINT FK_PostsCategories_Posts_PostId
        FOREIGN KEY(PostId)
        REFERENCES dbo.Posts(PostId),
      CONSTRAINT FK_PostsCategories_Categories_CategoryId
        FOREIGN KEY(CategoryId)
        REFERENCES dbo.Categories(CategoryId);
  
  ALTER TABLE dbo.PostsTags
    ADD
      CONSTRAINT FK_PostsTags_Posts_PostId
        FOREIGN KEY(PostId)
        REFERENCES dbo.Posts(PostId),
      CONSTRAINT FK_PostsTags_Tags_TagId
        FOREIGN KEY(TagId)
        REFERENCES dbo.Tags(TagId);

  ALTER TABLE dbo.Comments
    ADD
      CONSTRAINT FK_Comments_Posts_PostId
        FOREIGN KEY(PostId)
        REFERENCES dbo.Posts(PostId),
      CONSTRAINT FK_Comments_Users_UserId
        FOREIGN KEY(UserId)
        REFERENCES dbo.Users(UserId),
      CONSTRAINT FK_Comments_Comments_ParentId
        FOREIGN KEY(ParentId)
        REFERENCES dbo.Comments(CommentId);

END
GO

CREATE PROCEDURE dbo.CreateTestData
AS
BEGIN

  INSERT INTO dbo.Roles(Name)
    VALUES
      (N'Administrator'),
      (N'Author'),
      (N'Commentator');
  
  INSERT INTO dbo.States(Name)
     VALUES
      (N'Draft'),
      (N'Published'),
      (N'Archived'),
      (N'Hidden');
  
  INSERT INTO dbo.Tags(Name)
     VALUES
      (N'Story time'),
      (N'Me'),
      (N'Thanks'),
      (N'Must know'),
      (N'Illustrated');
  
  INSERT INTO dbo.Categories(Name)
    VALUES
      (N'Basics'),
      (N'Intermediate'),
      (N'Advanced');
  
  INSERT INTO dbo.Users (Name, Email, [Password], RoleId)
    VALUES
      (N'Jane Doe', 'jane.doe@gmail.com', 'passw0rd', 1),
      (N'John Palmer', 'j.palmer@gmail.com', 'qwerty123', 2),
      (N'Tonny', 'tonny@gmail.com', 'ynnot', 3);
  
  INSERT INTO dbo.Posts (Title, Body, UserId, StateId, Created)
     VALUES
      ( 
        N'Introduction',
        N'<p>There are many good books on homebrewing currently available, so why did I write one you ask? The answer is: a matter of perspective. When I began learning how to brew my own beer several years ago, I read every book I could find; books often published 15 years apart. It was evident to me that the state of the art had matured a bit. Where one book would recommend using baking yeast and covering the fermenting beer with a towel, a later book would insist on brewing yeast and perhaps an airlock. So, I felt that another point of view, laying out the hows and whys of the brewing processes, might help more new brewers get a better start.</p><p>Here is a synopsis of the brewing process:</p><ol><li>Malted barley is soaked in hot water to release the malt sugars.</li>	<li>The malt sugar solution is boiled with Hops for seasoning.</li>	<li>The solution is cooled and yeast is added to begin fermentation.</li>	<li>The yeast ferments the sugars, releasing CO2 and ethyl alcohol.</li>	<li>When the main fermentation is complete, the beer is bottled with a little bit of added sugar to provide the carbonation.</li></ol><p>Sounds fairly simple doesn''t it? It is, but as you read this book you will realize the incredible amount of information that I glossed over with those five steps. The first step alone can fill an entire book, several in fact. But brewing is easy. And it''s fun. Brewing is an art as well as a science. Some people may be put off by the technical side of things, but this is a science that you can taste. The science is what allows everyone to become the artist. Learning about the processes of beer making will let you better apply them as an artist. As my history teacher used to chide me, "It''s only boring until you learn something about it. Knowledge makes things interesting."</p><p>As an engineer, I was intrigued with the process of beermaking. I wanted to know what each step was supposed to be doing so I could understand how to better accomplish them. For instance, adding the yeast to the beer wort: the emphasis was to get the yeast fermenting as soon as possible to prevent unwanted competing yeasts or microbes from getting a foothold. There are actually several factors that influence yeast propagation, not all of which were explained in any one book. This kind of editing was an effort by the authors to present the information that they felt was most important to overall success and enjoyment of the hobby. Each of us has a different perspective.</p><p>Fortunately for me, I discovered the Internet and the homebrewing discussion groups it contained. With the help of veteran brewers on the Home Brew Digest (an Internet mailing list) and Rec.Crafts.Brewing (a Usenet newsgroup) I soon discovered why my first beer had turned out so brilliantly clear, yet fit only for mosquitoes to lay their eggs in. As I became more experienced, and was able to brew beer that could stand proudly with any commercial offering, I realized that I was seeing new brewers on the ''Net with the same basic questions that I had. They were reading the same books I had and some of those were excellent books. Well, I decided to write an electronic document that contained everything that a beginning brewer would need to know to get started. It contained equipment descriptions, process descriptions and some of the Why''s of homebrewing. I posted it to electronic bulletin boards and homebrewing archive computer sites such as Sierra.Stanford.edu . It was reviewed by other brewers and accepted as one of the best brewing guides available. It has been through four revisions as comments were received and I learned more about the Why''s of brewing. That document, "How To Brew Your First Beer" is still available and free to download and/or reproduce for personal use. It was written to help the first-time brewer produce a fool-proof beer - one they could be proud of. That document has apparently served quite well, it has been requested and distributed world-wide, including Europe, North America, Australia, Africa, and Asia- the Middle East and the Far East. Probably several thousand copies have been distributed by now. Glad I could help.</p><p>As time went by, and I moved on to Partial Mashes (half extract, half malted grain) and All-Grain Brewing, I actually saw requests on the ''Net from brewers requesting "Palmer-type" documents explaining these more complex brewing methods. There is a lot to talk about with these methods though, and I realized that it would be best done with a book. So, here we go...</p><p>Oh, one more thing, I should mention that Extract Brewing should not be viewed as inferior to brewing with grain, it is merely easier. It takes up less space and uses less equipment. You can brew national competition winning beers using extracts. The reason I moved on to Partial Mashes and then to All-Grain was because brewing is FUN. These methods really let you roll up your sleeves, fire up the kettles and be the inventor. You can let the mad-scientist in you come forth, you can combine different malts and hops at will, defying conventions and conservatives, raising your creation up to the storm and calling down the lightening...Hah hah HAH....</p><p>But I digress, thermo-nuclear brewing methods will be covered in another book. Okay, on with the show...</p>',
        1,
        2,
        DATEADD(DAY, -11, GETDATE())
      ),
      ( 
        N'Acknowledgments',
        N'<p>There are many good books on homebrewing currently available, so why did I write one you ask? The answer is: a matter of perspective. When I began learning how to brew my own beer several years ago, I read every book I could find; books often published 15 years apart. It was evident to me that the state of the art had matured a bit. Where one book would recommend using baking yeast and covering the fermenting beer with a towel, a later book would insist on brewing yeast and perhaps an airlock. So, I felt that another point of view, laying out the hows and whys of the brewing processes, might help more new brewers get a better start.</p><p>Here is a synopsis of the brewing process:</p><ol><li>Malted barley is soaked in hot water to release the malt sugars.</li>	<li>The malt sugar solution is boiled with Hops for seasoning.</li>	<li>The solution is cooled and yeast is added to begin fermentation.</li>	<li>The yeast ferments the sugars, releasing CO2 and ethyl alcohol.</li>	<li>When the main fermentation is complete, the beer is bottled with a little bit of added sugar to provide the carbonation.</li></ol><p>Sounds fairly simple doesn''t it? It is, but as you read this book you will realize the incredible amount of information that I glossed over with those five steps. The first step alone can fill an entire book, several in fact. But brewing is easy. And it''s fun. Brewing is an art as well as a science. Some people may be put off by the technical side of things, but this is a science that you can taste. The science is what allows everyone to become the artist. Learning about the processes of beer making will let you better apply them as an artist. As my history teacher used to chide me, "It''s only boring until you learn something about it. Knowledge makes things interesting."</p><p>As an engineer, I was intrigued with the process of beermaking. I wanted to know what each step was supposed to be doing so I could understand how to better accomplish them. For instance, adding the yeast to the beer wort: the emphasis was to get the yeast fermenting as soon as possible to prevent unwanted competing yeasts or microbes from getting a foothold. There are actually several factors that influence yeast propagation, not all of which were explained in any one book. This kind of editing was an effort by the authors to present the information that they felt was most important to overall success and enjoyment of the hobby. Each of us has a different perspective.</p><p>Fortunately for me, I discovered the Internet and the homebrewing discussion groups it contained. With the help of veteran brewers on the Home Brew Digest (an Internet mailing list) and Rec.Crafts.Brewing (a Usenet newsgroup) I soon discovered why my first beer had turned out so brilliantly clear, yet fit only for mosquitoes to lay their eggs in. As I became more experienced, and was able to brew beer that could stand proudly with any commercial offering, I realized that I was seeing new brewers on the ''Net with the same basic questions that I had. They were reading the same books I had and some of those were excellent books. Well, I decided to write an electronic document that contained everything that a beginning brewer would need to know to get started. It contained equipment descriptions, process descriptions and some of the Why''s of homebrewing. I posted it to electronic bulletin boards and homebrewing archive computer sites such as Sierra.Stanford.edu . It was reviewed by other brewers and accepted as one of the best brewing guides available. It has been through four revisions as comments were received and I learned more about the Why''s of brewing. That document, "How To Brew Your First Beer" is still available and free to download and/or reproduce for personal use. It was written to help the first-time brewer produce a fool-proof beer - one they could be proud of. That document has apparently served quite well, it has been requested and distributed world-wide, including Europe, North America, Australia, Africa, and Asia- the Middle East and the Far East. Probably several thousand copies have been distributed by now. Glad I could help.</p><p>As time went by, and I moved on to Partial Mashes (half extract, half malted grain) and All-Grain Brewing, I actually saw requests on the ''Net from brewers requesting "Palmer-type" documents explaining these more complex brewing methods. There is a lot to talk about with these methods though, and I realized that it would be best done with a book. So, here we go...</p><p>Oh, one more thing, I should mention that Extract Brewing should not be viewed as inferior to brewing with grain, it is merely easier. It takes up less space and uses less equipment. You can brew national competition winning beers using extracts. The reason I moved on to Partial Mashes and then to All-Grain was because brewing is FUN. These methods really let you roll up your sleeves, fire up the kettles and be the inventor. You can let the mad-scientist in you come forth, you can combine different malts and hops at will, defying conventions and conservatives, raising your creation up to the storm and calling down the lightening...Hah hah HAH....</p><p>But I digress, thermo-nuclear brewing methods will be covered in another book. Okay, on with the show...</p>',
        1,
        2,
        DATEADD(DAY, -10, GETDATE())
      ),
      (
        N'Glossary',
        N'<p>One of the first things a new brewer asks is, "What do I need to buy to get started?" and "What does that word mean?" For guidance to simple starter equipment setups for home brewing, see the <a href="http://howtobrew.com/book/equipment-descriptions">list of equipment</a> . The glossary of specialized terms on this page is divided into two groups -Basic and Advanced - to help you get started right away and let you progress as far as you like.</p><h4>Basic Terms</h4><p>The following fundamental terms will be used throughout this book.</p><p><strong>Ale -</strong> A beer brewed from a top-fermenting yeast with a relatively short, warm fermentation.</p><p><strong>Alpha Acid Units (AAU) -</strong> A homebrewing measurement of hops. Equal to the weight in ounces multiplied by the percent of alpha acids.</p><p><strong>Attenuation -</strong> The degree of conversion of sugar to alcohol and CO2.</p><p><strong>Beer -</strong> Any beverage made by fermenting a wort made from malted barley and seasoned with hops.</p><p><strong>Cold Break -</strong> Proteins that coagulate and fall out of solution when the wort is rapidly cooled prior to pitching the yeast.</p><p><strong>Conditioning -</strong> An aspect of secondary fermentation in which the yeast refine the flavors of the final beer. Conditioning continues in the bottle.</p><p><strong>Fermentation -</strong> The total conversion of malt sugars to beer, defined here as three parts, adaptation, primary, and secondary.</p><p><strong>Hops -</strong> Hop vines are grown in cool climates and brewers make use of the cone-like flowers. The dried cones are available in pellets, plugs, or whole.</p><p><strong>Hot Break -</strong> Proteins that coagulate and fall out of solution during the wort boil.</p><p><strong>Gravity -</strong> Like density, gravity describes the concentration of malt sugar in the wort. The specific gravity of water is 1.000 at 59F. Typical beer worts range from 1.035 - 1.055 before fermentation (Original Gravity).</p><p><strong>International Bittering Units (IBU) -</strong> A more precise unit for measuring hops. Equal to the AAU multiplied by factors for percent utilization, wort volume and wort gravity.</p><p><strong>Krausen (kroy-zen) -</strong> Used to refer to the foamy head that builds on top of the beer during fermentation. Also an advanced method of priming.</p><p><strong>Lager -</strong> A beer brewed from a bottom-fermenting yeast and given a long cool fermentation.</p><p><strong>Lag Phase -</strong> The period of adaptation and rapid aerobic growth of yeast upon pitching to the wort. The lag time typically lasts from 2-12 hours.</p><p><strong>Pitching -</strong> Term for adding the yeast to the fermenter.</p><p><strong>Primary Fermentation - </strong>The initial fermentation activity marked by the evolution of carbon dioxide and Krausen. Most of the total attenuation occurs during this phase.</p><p><strong>Priming -</strong> The method of adding a small amount of fermentable sugar prior to bottling to give the beer carbonation.</p><p><strong>Racking -</strong> The careful siphoning of the beer away from the trub.</p><p><strong>Sanitize -</strong> To reduce microbial contaminants to insignificant levels.</p><p><strong>Secondary Fermentation -</strong> A period of settling and conditioning of the beer after primary fermentation and before bottling.</p><p><strong>Sterilize -</strong> To eliminate all forms of life, especially microorganisms, either by chemical or physical means.</p><p><strong>Trub (trub or troob) -</strong> The sediment at the bottom of the fermenter consisting of hot and cold break material, hop bits, and dead yeast.</p><p><strong>Wort (wart or wert) -</strong> The malt-sugar solution that is boiled prior to fermentation.</p><p><strong>Zymurgy -</strong> The science of brewing and fermentation.</p><h4>Advanced Terms</h4><p>The following terms are more advanced and are more likely to come up as you progress in your home brewing skills and experience.</p><p><strong>Amylase</strong> - An enzyme group that converts starches to sugars, consisting primarily of alpha and beta amylase. Also referred to as the diastatic enzymes.</p><p><strong>Adjunct</strong> - Any non-enzymatic fermentable. Adjuncts include: unmalted cereals such as flaked barley or corn grits, syrups, and sugars.</p><p><strong>Acrospire</strong> - The beginnings of the plant shoot in germinating barley.</p><p><strong>Aerate</strong> - To mix air into solution to provide oxygen for the yeast.</p><p><strong>Aerobic</strong> - A process that utilizes oxygen.</p><p><strong>Anaerobic</strong> - A process that does not utilize oxygen or may require the absence of it.</p><p><strong>Aldehyde</strong> - A chemical precursor to alcohol. In some cases, alcohol can be oxidized to aldehydes, creating off-flavors.</p><p><strong>Alkalinity</strong> - The condition of pH between 7-14. The chief cause of alkalinity in brewing water is the bicarbonate ion (HCO<sub>3</sub><sup>-1</sup>).</p><p><strong>Aleurone Layer</strong> - The living sheath surrounding the endosperm of a barley corn, containing enzymes.</p><p><strong>Amino Acids</strong> - An essential building block of protein, being comprised of an organic acid containing an amine group (NH2).</p><p><strong>Amylopectin</strong> - A branched starch chain found in the endosperm of barley. It can be considered to be composed of amylose.</p><p><strong>Amylose</strong> - A straight-chain starch molecule found in the endosperm of barley.</p><p><strong>Autolysis</strong> - When yeast run out of nutrients and die, they release their innards into the beer, producing off-flavors.</p><p><strong>°Balling, °Brix, or °Plato</strong> - These three nearly identical units are the standard for the professional brewing industry for describing the amount of available extract as a weight percentage of cane sugar in solution, as opposed to specific gravity. Eg. 10 °Plato is equivalent to a specific gravity of 1.040.</p><p><strong>Beerstone</strong> - A hard organo-metallic scale that deposits on fermentation equipment; chiefly composed of calcium oxalate.</p><p><strong>Biotin</strong> - A colorless crystalline vitamin of the B complex, found especially in yeast, liver, and egg yolk.</p><p><strong>Blow-off</strong> - A type of airlock arrangement consisting of a tube exiting from the fermenter, submerging into a bucket of water, that allows the release of carbon dioxide and removal of excess fermentation material.</p><p><strong>Buffer</strong> - A chemical species, such as a salt, that by disassociation or re-association stabilizes the pH of a solution.</p><p><strong>Cellulose</strong> - Similar to a starch, but organized in a mirror aspect; cellulose cannot be broken down by starch enzymes, and vice versa.</p><p><strong>Decoction</strong> - A method of mashing wherein temperature rests are achieved by boiling a part of the mash and returning it to the mash tun.</p><p><strong>Dextrin</strong> - A complex sugar molecule, left over from diastatic enzyme action on starch.</p><p><strong>Dextrose</strong> - Equivalent to Glucose, but with a mirror-image molecular structure.</p><p><strong>Diastatic Power</strong> - The amount of diastatic enzyme potential that a malt contains.</p><p><strong>Dimethyl Sulfide (DMS)</strong> - A background flavor compound that is desirable in low amounts in lagers, but that at high concentrations tastes of cooked vegetables.</p><p><strong>Enzymes</strong> - Protein-based catalysts that effect specific biochemical reactions.</p><p><strong>Endosperm</strong> - The nutritive tissue of a seed, consisting of carbohydrates, proteins, and lipids.</p><p><strong>Esters</strong> - Aromatic compounds formed from alcohols by yeast action. Typically smell fruity.</p><p><strong>Ethanol</strong> - The type of alcohol in beer formed by yeast from malt sugars.</p><p><strong>Extraction</strong> - The soluble material derived from barley malt and adjuncts. Not necessarily fermentable.</p><p><strong>Fatty Acid</strong> - Any of numerous saturated or unsaturated aliphatic monocarboxylic acids, including many that occur in the form of esters or glycerides, in fats, waxes, and essential oils.</p><p><strong>Finings</strong> - Ingredients such as isinglass, bentonite, Irish moss, etc, that act to help the yeast to flocculate and settle out of finished beer.</p><p><strong>Flocculation</strong> - To cause to group together. In the case of yeast, it is the clumping and settling of the yeast out of solution.</p><p><strong>Fructose</strong> - Commonly known as fruit sugar, fructose differs from glucose by have a ketone group rather than an aldehydic carbonyl group attachment.</p><p><strong>Fusel Alcohol</strong> - A group of higher molecular weight alcohols that esterify under normal conditions. When present after fermentation, fusels have sharp solvent-like flavors and are thought to be partly responsible for hangovers.</p><p><strong>Gelatinization</strong> - The process of rendering starches soluble in water by heat, or by a combination of heat and enzyme action, is called gelatinization.</p><p><strong>Germination</strong> - Part of the malting process where the acrospire grows and begins to erupt from the hull.</p><p><strong>Glucose</strong> - The most basic unit of sugar. A single sugar molecule.</p><p><strong>Glucanase</strong> - An enzyme that act on beta glucans, a type of gum found in the endosperm of unmalted barley, oatmeal, and wheat.</p><p><strong>Grist</strong> - The term for crushed malt before mashing.</p><p><strong>Hardness</strong> - The hardness of water is equal to the concentration of dissolved calcium and magnesium ions. Usually expressed as ppm of (CaCO<sub>3</sub>).</p><p><strong>Hydrolysis</strong> - The process of dissolution or decomposition of a chemical structure in water by chemical or biochemical means.</p><p><strong>Hopback</strong> - A vessel that is filled with hops to act as a filter for removing the break material from the finished wort.</p><p><strong>Hot Water Extract</strong> - The international unit for the total soluble extract of a malt, based on specific gravity. HWE is measured as liter*degrees per kilogram, and is equivalent to points/pound/gallon (PPG) when you apply metric conversion factors for volume and weight. The combined conversion factor is 8.3454 X PPG = HWE.</p><p><strong>Infusion</strong> - A mashing process where heating is accomplished via additions of boiling water.</p><p><strong>Invert Sugar</strong> - A mixture of dextrose and fructose found in fruits or produced artificially by the inversion of sucrose (e.g. hydrolyzed cane sugar).</p><p><strong>Isinglass</strong> - The clear swim bladders of a small fish, consisting mainly of the structural protein collagen, acts to absorb and precipitate yeast cells, via electrostatic binding.</p><p><strong>Irish Moss</strong> - An emulsifying agent, Irish moss promotes break material formation and precipitation during the boil and upon cooling.</p><p><strong>Lactose</strong> - A nonfermentable sugar, lactose comes from milk and has historically been added to Stout, hence Milk Stout.</p><p><strong>Lauter</strong> - To strain or separate. Lautering acts to separate the wort from grain via filtering and sparging.</p><p><strong>Lipid</strong> - Any of various substances that are soluble in nonpolar organic solvents, and that include fats, waxes, phosphatides, cerebrosides, and related and derived compounds. Lipids, proteins, and carbohydrates compose the principal structural components of living cells.</p><p><strong>Liquefaction</strong> - As alpha amylase breaks up the branched amylopectin molecules in the mash, the mash becomes less viscous and more fluid; hence the term liquefaction of the mash and alpha amylase being referred to as the liquefying enzyme.</p><p><strong>Lupulin Glands</strong> - Small bright yellow nodes at the base of each of the hop petals, which contain the resins utilized by brewers.</p><p><strong>Maillard Reaction</strong> - A browning reaction caused by external heat wherein a sugar (glucose) and an amino acid form a complex, and this product has a role in various subsequent reactions that yield pigments and melanoidins.</p><p><strong>Maltose</strong> - The preferred food of brewing yeast. Maltose consists of two glucose molecules joined by a 1-4 carbon bond.</p><p><strong>Maltotriose</strong> - A sugar molecule made of three glucoses joined by 1-4 carbon bonds.</p><p><strong>Melanoidins</strong> - Strong flavor compounds produced by browning (Maillard) reactions.</p><p><strong>Methanol</strong> - Also known as wood alcohol, methanol is poisonous and cannot be produced in any significant quantity by the beer making process.</p><p><strong>Mash</strong> - The hot water steeping process that promotes enzymatic breakdown of the grist into soluble, fermentable sugars.</p><p><strong>Modification</strong> - An inclusive term for the degree of degradation and simplification of the endosperm and the carbohydrates, proteins, and lipids that comprise it.</p><p><strong>pH</strong> - A negative logarithmic scale (1-14) that measures the degree of acidity or alkalinity of a solution for which a value of 7 represents neutrality. A value of 1 is most acidic, a value of 14 is most alkaline.</p><p><strong>ppm</strong> - The abbreviation for parts per million and equivalent to milligrams per liter (mg/l). Most commonly used to express dissolved mineral concentrations in water.</p><p><strong>Peptidase</strong> - A proteolytic enzyme which breaks up small proteins in the endosperm to form amino acids.</p><p><strong>Points per Pound per Gallon (PPG)</strong> - The US homebrewers unit for total soluble extract of a malt, based on specific gravity. The unit describes the change in specific gravity (points) per pound of malt, when dissolved in a known volume of water (gallons). Can also be written as gallon*degrees per pound.</p><p><strong>Protease</strong> - A proteolytic enzyme which breaks up large proteins in the endosperm that would cause haze in the beer.</p><p><strong>Phenol, Polyphenol</strong> - A hydroxyl derivative of an aromatic hydrocarbon that causes medicinal flavors and is involved in staling reactions.</p><p><strong>Proteolysis</strong> - The degradation of proteins by proteolytic enzymes e.g. protease and peptidase.</p><p><strong>Saccharification</strong> - The conversion of soluble starches to sugars via enzymatic action.</p><p><strong>Sparge</strong> - To sprinkle. To rinse the grainbed during lautering.</p><p><strong>Sterols</strong> - Any of various solid steroid alcohols widely distributed in plant and animal lipids.</p><p><strong>Sucrose</strong> - This disaccharide consists of a fructose molecule joined with a glucose molecule. It is most readily available as cane sugar.</p><p><strong>Tannins</strong> - Astringent polyphenol compounds that can cause haze and/or join with large proteins to precipitate them from solution. Tannins are most commonly found in the grain husks and hop cone material.</p>',
        1,
        2,
        DATEADD(DAY, -5, GETDATE())
      ),
      ( 
        N'Equipment',
        N'<p>An obvious first question most new brewers ask is, "What do I need to get started?" None of the equipment setups in home brewing require a degree in rocket science, and some of the needed equipment you may already have on hand. Start-up costs will depend what you already have and how elaborate you want to get. Initial cost will vary from $20 to $100 U.S.</p><p><img src="http://howtobrew.com/assets/img/assets/equipment.jpg" alt="equipment.jpg#asset:637"><br></p><p><strong>Airlock</strong> - Several styles are available. They are filled with water to prevent contamination from the outside atmosphere.</p><p><img src="http://howtobrew.com/assets/img/assets/airlocks.gif" alt="airlocks.gif#asset:634"><br></p><p><strong>Boiling Pot</strong> - Must be able to comfortably hold a minimum of 3 gallons; bigger is better. Use quality pots made of stainless steel, aluminum, or ceramic-coated steel. A 5 gallon home canning pot (those black, speckled ones) is the least expensive and a good choice for getting started.</p><p><strong>Bottles</strong> - You will need (48) recappable 12 oz bottles for a typical 5 gallon batch. Alternatively, (30) of the larger 22 oz bottles may be used to reduce capping time. Twist-offs do not re-cap well and are more prone to breaking. Used champagne bottles are ideal if you can find them.</p><p><strong>Bottle Capper</strong> - Two styles are available: hand cappers and bench cappers. Bench cappers are more versatile and are needed for the champagne bottles, but are more expensive.</p><p><strong>Bottle Caps</strong> - Either standard or oxygen absorbing crown caps are available.</p><p><strong>Bottle Brush</strong> - A long handled nylon bristle brush is necessary for the first, hard-core cleaning of used bottles.</p><p><strong>Fermenter</strong> - The 6 gallon food-grade plastic pail is recommended for beginners. These are very easy to work with. Glass carboys are also available, in 3, 5, and 6.5 gallon sizes. The carboy is shown with a blowoff hose which ends in a bucket of water.</p><p> <img src="http://howtobrew.com/assets/img/assets/bucandcar.gif" alt="bucandcar.gif#asset:636"><br></p><p><strong>Pyrex(tm) Measuring Cup</strong> - The quart-size or larger measuring cup will quickly become one of your most invaluable tools for brewing. The heat resistant glass ones are best because they can be used to measure boiling water and are easily sanitized.</p><p><strong>Siphon</strong> - Available in several configurations, usually consisting of clear plastic tubing with a racking cane and optional bottle filler.</p><p><strong>Racking Cane</strong> - Rigid plastic tube with sediment stand-off used to leave the trub behind when siphoning.</p><p><strong>Bottle Filler</strong> - Rigid plastic (or metal) tube often with a spring loaded valve at the tip for filling bottles.</p><p><img src="http://howtobrew.com/assets/img/assets/siphon.gif" alt="siphon.gif#asset:639"><br></p><p><strong>Stirring Paddle</strong> - Food grade plastic paddle (or spoon) for stirring the wort during boiling.</p><p><strong>Thermometer</strong>- Obtain a thermometer that can be safely immersed in the wort and has a range of at least 40F to 180F. The floating dairy thermometers work very well. Dial thermometers read quickly and are inexpensive.</p><p><img src="http://howtobrew.com/assets/img/assets/thermometer.gif" alt="thermometer.gif#asset:640"><br></p><p><strong>Optional but Highly Recommended</strong> </p><p><strong>Bottling Bucket</strong> - A 6 gallon food-grade plastic pail with attached spigot and fill-tube. The finished beer is racked into this for priming prior to bottling. Racking into the bottling bucket allows clearer beer with less sediment in the bottle. The spigot is used instead of the bottle filler, allowing greater control of the fill level and no hassles with a siphon during bottling.</p><p><img src="http://howtobrew.com/assets/img/assets/bbucket.gif" alt="bbucket.gif#asset:635"><br></p><p><strong>Hydrometer</strong> - A hydrometer measures the relative specific gravity between pure water and water with sugar dissolved in it by how high it floats when immersed. The hydrometer is used to gauge the fermentation progress by measuring one aspect of it, attenuation. Hydrometers are necessary when making beer from scratch (all-grain brewing) or when designing recipes. The first-time brewer using known quantities of extracts usually does not need one, but it can be a useful tool. See Appendix A - Using Hydrometers.</p><p><img src="http://howtobrew.com/assets/img/assets/hydrometer.jpg" alt="hydrometer.jpg#asset:638"><br></p><p><strong>Wine Thief or Turkey Baster</strong> - These things are very handy for withdrawing samples of wort or beer from the fermenter without risking contamination of the whole batch.</p><p><strong>Equipment Kit Comparison</strong>(1999 prices)</p><table><tbody><tr><td><strong>College Student Budget Package</strong> </td> <td> </td> <td><strong>Complete Beginners Package</strong> </td> <td> </td> </tr><tr><td>Ceramic on Steel Boiling Pot (5 gal) </td> <td>$20 </td> <td>Ceramic on Steel Boiling Pot (5 gal) </td> <td>$20 </td> </tr><tr><td>1 Fermentor with Airlock </td> <td>$10 </td> <td>2 Fermentors with Airlocks<br>(1 Fermenter doubles as Bottling Bucket) </td> <td>$20 </td> </tr><tr><td>Siphon </td> <td>$4 </td> <td>Siphon w/ Bottle Filler </td> <td>$6 </td> </tr><tr><td>Bottle Capper (hand) </td> <td>$15 </td> <td>Bottle Capper (Bench) </td> <td>$25 </td> </tr><tr><td>Bottle Caps (gross) </td> <td>$3 </td> <td>Bottle Caps (gross) </td> <td>$3 </td> </tr><tr><td>Large Stirring Spoon </td> <td>$2 </td> <td>Large Stirring Spoon </td> <td>$2 </td> </tr><tr><td>Bottle Brush </td> <td>$3 </td> <td>Bottle Brush </td> <td>$3 </td> </tr><tr><td> </td> <td> </td> <td>Thermometer </td> <td>$6 </td> </tr><tr><td> </td> <td> </td> <td>Hydrometer </td> <td>$5 </td> </tr><tr><td>Ingredients Kit </td> <td>$20 </td> <td>Ingredients Kit </td> <td>$20 </td> </tr><tr><td><strong>Total</strong> </td> <td><strong>$77</strong> </td> <td> </td> <td><strong>$110</strong> </td> </tr></tbody></table><p>You will usually find beginner''s kit packages at homebrew supply shops containing the majority of these items for $60 -$80. The prices shown above are for estimating your costs if you purchased items separately.</p>',
        1,
        1,
        GETDATE()
      );
  
  INSERT INTO dbo.PostsCategories(PostId, CategoryId)
    VALUES
      (1, 1),
      (2, 1),
      (3, 2),
      (4, 3);
  
  INSERT INTO dbo.PostsTags(PostId, TagId)
    VALUES
      (1, 1),
      (1, 2),
      (2, 2),
      (2, 3),
      (3, 4),
      (4, 4),
      (4, 5);
  
  INSERT INTO dbo.[Permissions] (Name)
    VALUES
      (N'Read'),
      (N'Establish'),
      (N'Edit'),
      (N'Delete');
  
  INSERT INTO dbo.RolesPermissions (RoleId, PermissionId)
    VALUES
      -- Administrator
      (1, 1),
      (1, 2),
      (1, 3),
      (1, 4),
      -- Author
      (2, 1),
      (2, 2),
      (2, 3);
  
  INSERT INTO dbo.Categories (Name, ParentId)
    VALUES
      (N'Beginning brewer', 1),
      (N'Thermo-nuclear brewing', 3),
      (N'Home brewing', 4),
      (N'Basement', 6);

  INSERT INTO dbo.Comments (PostId, UserId, Created, Body, ParentId)
    VALUES
      (3, 3, DATEADD(DAY, -4, GETDATE()), N'Pretty cool content! Keep it up!', NULL),
      (3, 2, DATEADD(DAY, -4, GETDATE()), N'Totally agree', 1);

END
GO

CREATE PROCEDURE dbo.EstablishDB
AS
BEGIN

  BEGIN TRAN;

    EXECUTE dbo.CreateTables;
    EXECUTE dbo.CreateForeignKeys;

  COMMIT TRAN;

END
GO

EXECUTE dbo.EstablishDB;
GO

CREATE TRIGGER TriggerPostAudit
  ON dbo.Posts
  AFTER INSERT, UPDATE, DELETE
AS
BEGIN

  SET NOCOUNT ON;

  --
  -- Check if this is an INSERT, UPDATE or DELETE Action.
  -- 
  DECLARE @action AS CHAR(1);
  
  SET @action = 'I'; -- Set Action to Insert by default.
  IF EXISTS(SELECT * FROM DELETED)
  BEGIN
      
      SET @action = 
          CASE
              WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' -- Set Action to Updated.
              ELSE 'D' -- Set Action to Deleted.       
          END
  END
  ELSE 
      IF NOT EXISTS(SELECT * FROM INSERTED) RETURN; -- Nothing updated or inserted.
  
  -- Create a log record
  IF @action = 'I' OR @action = 'U'
  BEGIN
    INSERT INTO dbo.PostLog ([Action], PostId, PostTitle)
    SELECT @action AS [Action], PostId, Title FROM INSERTED;
  END

  ELSE
  BEGIN
    INSERT INTO dbo.PostLog ([Action], PostId, PostTitle)
    SELECT @action AS [Action], PostId, Title FROM DELETED;
  END

END
GO

EXECUTE dbo.CreateTestData;
GO

CREATE PROCEDURE dbo.GetTagNamesForPost
  @PostId AS INT
AS
BEGIN

  SELECT 
    T.TagId,
    T.Name
  FROM dbo.PostsTags AS PT
    INNER JOIN dbo.Tags AS T 
      ON PT.TagId = T.TagId
  WHERE PT.PostId = @PostId;

END
GO

CREATE PROCEDURE dbo.GetLatestPublishedPosts
  @Limit AS INT = 10
AS
BEGIN

  SELECT
    PostId,
    Title,
    Body,
    UserId,
    StateId
  FROM dbo.Posts
  WHERE StateId = 2 -- Published
  ORDER BY PostId DESC
  OFFSET 0 ROWS FETCH FIRST @Limit ROWS ONLY;

END
GO

CREATE VIEW dbo.NumberOfPostsPerCategory
AS

SELECT
	C.CategoryId,
	C.Name,
	COUNT(*) AS PostsInCategory
FROM dbo.PostsCategories AS PC
	INNER JOIN dbo.Categories C
	  ON PC.CategoryId = C.CategoryId
GROUP BY C.CategoryId, C.Name;

GO

CREATE PROCEDURE dbo.SearchPostByPartialInTitleAndBody
  @PartialTitle AS NVARCHAR(255),
  @PartialBody AS NVARCHAR(255)
AS
BEGIN

  SELECT
    PostId,
    Title,
    Body,
    Created,
    Edited,
    UserId,
    StateId
  FROM dbo.Posts
  WHERE Title LIKE N'%' + @PartialTitle + '%' AND Body LIKE N'%' + @PartialBody +'%';

END
GO

CREATE PROCEDURE dbo.GetLatestPostsWithTagsAndCategories
  @ForDays AS INT = 10
AS
BEGIN

  SELECT
    U.Name AS Author,
    P.Title,
    P.Created,
    P.Edited,
    T.Name AS TagName,
    C.Name AS CategoryName
  FROM dbo.Posts AS P
    INNER JOIN dbo.Users AS U
      ON P.UserId = U.UserId
    LEFT OUTER JOIN dbo.PostsCategories AS PC
      ON P.PostId = PC.PostId
    INNER JOIN dbo.Categories AS C
      ON PC.CategoryId = C.CategoryId
    LEFT OUTER JOIN dbo.PostsTags AS PT
      ON P.PostId = PT.PostId
    INNER JOIN dbo.Tags AS T
      ON PT.TagId = T.TagId
    INNER JOIN dbo.States AS S
      ON P.StateId = S.StateId
  WHERE (S.Name = N'Published' OR S.Name = N'Archived')
    AND P.Created >= DATEADD(DAY, -@ForDays, CAST(GETDATE() AS DATE));

END
GO

CREATE VIEW dbo.FirstLevelCategories
AS

SELECT
  CategoryId,
  Name
FROM dbo.Categories
WHERE ParentId IS NULL;

GO

CREATE VIEW dbo.FirstAndSecondLevelCategries
AS

SELECT
  L1.CategoryId AS L1CategoryId,
  L1.Name AS L1Name,
  L2.CategoryId AS L2CategoryId,
  L2.Name AS L2Name
FROM dbo.Categories AS L1
  LEFT OUTER JOIN dbo.Categories AS L2
    ON L1.CategoryId = L2.ParentId
WHERE L1.ParentId IS NULL;

GO

/*
  A view that displays all tags order by popularity.
  It will be used to display tag cloud on the blog page.
*/

CREATE VIEW dbo.TagCloud
AS

SELECT
  T.TagId,
  T.Name,
  COUNT(*) AS NumberOfPosts
FROM dbo.PostsTags AS PT
  INNER JOIN dbo.Tags AS T
    ON PT.TagId = T.TagId
GROUP BY T.TagId, T.Name

GO

/*
  Returns a table with latest comments
  Will be used in sidebar to show posts that have active discussions.
*/
CREATE PROCEDURE dbo.GetRecentComments
  @Limit AS INT = 10
AS
BEGIN

  SELECT 
    C.CommentId,
    P.PostId,
    P.Title AS PostTitle,
    U.UserId,
    U.Name AS UserName
  FROM dbo.Comments AS C
    INNER JOIN dbo.Posts AS P
      ON C.PostId = P.PostId
    INNER JOIN dbo.Users AS U
      ON C.UserId = U.UserId
  ORDER BY C.Created DESC
  OFFSET 0 ROWS FETCH FIRST @Limit ROWS ONLY;

END
GO

/*
  Returns comments that are associated with a blog post.
  It will be used to diplay comments under the post.
*/
CREATE PROCEDURE dbo.GetCommentForBlogPost
  @PostId AS INT
AS
BEGIN

  SELECT
    C.CommentId,
    C.Body AS Comment,
    C.Created,
    C.Edited,
    C.ParentId,
    U.UserId,
    U.Name
  FROM dbo.Comments AS C
    INNER JOIN dbo.Users AS U
      ON C.UserId = U.UserId
  WHERE C.PostId = @PostId;

END
GO

/*
  Return users with their roles and permissions
  Will be get overview of what all users can do.
*/

CREATE VIEW dbo.UsersPermissionsRoles
AS

SELECT
  U.UserId,
  U.Name,
  U.Email,
  R.Name AS [Role],
  P.Name AS Permission
FROM dbo.Users AS U
  INNER JOIN Roles AS R
    ON U.RoleId = R.RoleId
  LEFT OUTER JOIN RolesPermissions AS RP
    ON R.RoleId = RP.RoleId
  LEFT OUTER JOIN [Permissions] AS P
    ON RP.PermissionId = P.PermissionId;

GO

/*
  Deletes post and post's comments.
*/

CREATE PROCEDURE dbo.DeletePost
  @PostId AS INT
AS
BEGIN

  BEGIN TRAN;
    
    DELETE FROM dbo.PostsCategories
    WHERE PostId = @PostId;

    DELETE FROM dbo.PostsTags
    WHERE PostId = @PostId;

    DELETE FROM dbo.Comments
    WHERE PostId = @PostId;

    DELETE FROM dbo.Posts
    WHERE PostId = @PostId;

  COMMIT TRAN;

END
GO

--EXECUTE dbo.GetTagNamesForPost @PostId = 4;
--EXECUTE dbo.GetLatestPublishedPosts;
--EXECUTE dbo.SearchPostByPartialInTitleAndBody @PartialTitle=N'Equipment', @PartialBody=N'Airlock';
--EXECUTE dbo.GetLatestPostsWithTagsAndCategories;
--EXECUTE dbo.GetRecentComments;
--EXECUTE dbo.GetCommentForBlogPost @PostId = 3;
--EXECUTE dbo.DeletePost @PostId = 3;