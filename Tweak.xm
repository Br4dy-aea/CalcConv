#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

static UILabel *conversionLabel;
static UIButton *menuButton;
static UIButton *reverseButton;
static __strong NSString *selectedConversion = nil;

    
    
    NSString *fallbackDisplayValue();
    NSString *convertValue(NSString *input);
    NSString *reversedConversionKey(NSString *key);

       @interface ConversionHelper : NSObject <UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource>
        @property (nonatomic, strong) NSArray<NSDictionary *> *allConversions;
        @property (nonatomic, strong) NSArray<NSDictionary *> *filteredResults;
        @property (nonatomic, strong) UISearchController *searchController;
        @property (nonatomic, strong) UITableView *resultsTable;
        @property (nonatomic, strong) NSDictionary<NSString *, NSArray<NSDictionary *> *> *categories;
        @property (nonatomic, strong) NSArray<NSString *> *categoryKeys;
        @property (nonatomic, assign) BOOL isSearching;
        @end

@implementation ConversionHelper

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.searchController.isActive) return nil;

    UIView *container = [[UIView alloc] init];
    container.backgroundColor = [UIColor clearColor];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 6, tableView.frame.size.width - 32, 28)];
    label.text = self.categoryKeys[section];
    label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    label.textColor = [UIColor secondaryLabelColor];
    label.backgroundColor = [UIColor secondarySystemBackgroundColor];
    label.layer.cornerRadius = 10;
    label.layer.masksToBounds = YES;
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 1;

    [container addSubview:label];
    return container;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.searchController.isActive ? 0 : 40;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.searchController.isActive ? 1 : self.categoryKeys.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.searchController.isActive) return nil;
    return self.categoryKeys[section];
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _allConversions = @[]; // Will populate later
    }
    return self;
}
   - (void)reverseConversion {
    if (selectedConversion) {
        selectedConversion = reversedConversionKey(selectedConversion);
        [self triggerConversion];
    }
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *query = searchController.searchBar.text.lowercaseString;
    self.filteredResults = [self.allConversions filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary *conv, NSDictionary *bindings) {
        return [[conv[@"label"] lowercaseString] rangeOfString:query options:NSCaseInsensitiveSearch].location != NSNotFound;
    }]];
    [self.resultsTable reloadData];
}

void fetchLiveRate(NSString *from, NSString *to, void (^completion)(double rate));

- (void)showMenu {
    UIWindowScene *scene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
    UIWindow *window = scene.windows.firstObject;
    UIViewController *rootVC = window.rootViewController;

    
    NSMutableArray *all = [NSMutableArray array];
    NSDictionary *categories = @{
        @"Pressure": @[
            @{ @"label": @"Pascal → PSI", @"key": @"paToPsi" },
            @{ @"label": @"PSI → Pascal", @"key": @"psiToPa" },
            @{ @"label": @"bar → atmosphere", @"key": @"barToAtm" },
            @{ @"label": @"atm → bar", @"key": @"atmToBar" },
            @{ @"label": @"Torr → Pascal", @"key": @"torrToPa" },
            @{ @"label": @"Pascal → Torr", @"key": @"paToTorr" },
            @{ @"label": @"inHg → kPa", @"key": @"inhgToKpa" },
            @{ @"label": @"kPa → inHg", @"key": @"kpaToInhg" },
            @{ @"label": @"PSI → bar", @"key": @"psiToBar" },
            @{ @"label": @"bar → PSI", @"key": @"barToPsi" }
        ],
        @"Temperature": @[
            @{ @"label": @"Celsius → Fahrenheit", @"key": @"cToF" },
            @{ @"label": @"Fahrenheit → Celsius", @"key": @"fToC" },
            @{ @"label": @"Celsius → Kelvin", @"key": @"cToK" },
            @{ @"label": @"Kelvin → Celsius", @"key": @"kToC" },
            @{ @"label": @"Fahrenheit → Kelvin", @"key": @"fToK" },
            @{ @"label": @"Kelvin → Fahrenheit", @"key": @"kToF" }
            
        ],
        @"Length": @[
            @{ @"label": @"Foot → Meter", @"key": @"ftToM" },
            @{ @"label": @"Meter → Foot", @"key": @"mToFt" },
            @{ @"label": @"Inch → Centimeter", @"key": @"inToCm" },
            @{ @"label": @"Centimeter → Inch", @"key": @"cmToIn" },
            @{ @"label": @"Mile → Kilometer", @"key": @"miToKm" },
            @{ @"label": @"Kilometer → Mile", @"key": @"kmToMi" },
            @{ @"label": @"Yard → Meter", @"key": @"ydToM" },
            @{ @"label": @"Meter → Yard", @"key": @"mToYd" },
            @{ @"label": @"Millimeter → Inch", @"key": @"mmToIn" },
            @{ @"label": @"Inch → Millimeter", @"key": @"inToMm" },
            @{ @"label": @"Decimeter → Meter", @"key": @"dmToM" },
            @{ @"label": @"Meter → Decimeter", @"key": @"mToDm" },
            @{ @"label": @"Light Year → Kilometer", @"key": @"lyToKm" },
            @{ @"label": @"Kilometer → Light Year", @"key": @"kmToLy" },
            @{ @"label": @"Parsec → Light Year", @"key": @"pcToLy" },
            @{ @"label": @"Light Year → Parsec", @"key": @"lyToPc" },
            @{ @"label": @"Nautical Mile → Kilometer", @"key": @"nmToKm" },
            @{ @"label": @"Kilometer → Nautical Mile", @"key": @"kmToNm" },
            @{ @"label": @"Astronomical Unit → Kilometer", @"key": @"auToKm" },
            @{ @"label": @"Kilometer → Astronomical Unit", @"key": @"kmToAu" }
         ],
        @"Speed": @[
            @{ @"label": @"Meters/sec → Kilometers/hour", @"key": @"mpsToKph" },
            @{ @"label": @"Kilometers/hour → Meters/sec", @"key": @"kphToMps" },
            @{ @"label": @"Feet/sec → Meters/sec", @"key": @"fpsToMps" },
            @{ @"label": @"Meters/sec → Feet/sec", @"key": @"mpsToFps" },
            @{ @"label": @"Miles/hour → Kilometers/hour", @"key": @"mphToKph" },
            @{ @"label": @"Kilometers/hour → Miles/hour", @"key": @"kphToMph" },
            @{ @"label": @"Knots → Kilometers/hour", @"key": @"knotToKph" },
            @{ @"label": @"Kilometers/hour → Knots", @"key": @"kphToKnot" }
         ],
        @"Weight": @[
            @{ @"label": @"Dram → Gram", @"key": @"dramToG" },
            @{ @"label": @"Gram → Dram", @"key": @"gToDram" },
            @{ @"label": @"Kilogram → Pound", @"key": @"kgToLb" },
            @{ @"label": @"Pound → Kilogram", @"key": @"lbToKg" },
            @{ @"label": @"Ounce → Gram", @"key": @"ozToG" },
            @{ @"label": @"Gram → Ounce", @"key": @"gToOz" },
            @{ @"label": @"Milligram → Gram", @"key": @"mgToG" },
            @{ @"label": @"Gram → Milligram", @"key": @"gToMg" },
            @{ @"label": @"Stone → Kilogram", @"key": @"stToKg" },
            @{ @"label": @"Kilogram → Stone", @"key": @"kgToSt" },
            @{ @"label": @"Short Ton → Kilogram", @"key": @"tonToKg" },
            @{ @"label": @"Kilogram → Short Ton", @"key": @"kgToTon" },
            @{ @"label": @"Metric Tonne → Kilogram", @"key": @"tToKg" },
            @{ @"label": @"Kilogram → Metric Tonne", @"key": @"kgToT" },
            @{ @"label": @"Long Ton → Kilogram", @"key": @"longTonToKg" },
            @{ @"label": @"Kilogram → Long Ton", @"key": @"kgToLongTon" },
            @{ @"label": @"Slug → Kilogram", @"key": @"slugToKg" },
            @{ @"label": @"Kilogram → Slug", @"key": @"kgToSlug" },
            @{ @"label": @"Troy Ounce → Gram", @"key": @"tozToG" },
            @{ @"label": @"Gram → Troy Ounce", @"key": @"gToToz" }
         ],
        @"Time": @[
            @{ @"label": @"Second → Millisecond", @"key": @"sToMs" },
            @{ @"label": @"Millisecond → Second", @"key": @"msToS" },
            @{ @"label": @"Minute → Second", @"key": @"minToS" },
            @{ @"label": @"Second → Minute", @"key": @"sToMin" },
            @{ @"label": @"Hour → Minute", @"key": @"hrToMin" },
            @{ @"label": @"Minute → Hour", @"key": @"minToHr" },
            @{ @"label": @"Day → Hour", @"key": @"dayToHr" },
            @{ @"label": @"Hour → Day", @"key": @"hrToDay" },
            @{ @"label": @"Week → Day", @"key": @"wkToDay" },
            @{ @"label": @"Day → Week", @"key": @"dayToWk" },
            @{ @"label": @"Year → Day", @"key": @"yrToDay" },
            @{ @"label": @"Day → Year", @"key": @"dayToYr" },
            @{ @"label": @"Second → Microsecond", @"key": @"sToUs" },
            @{ @"label": @"Microsecond → Second", @"key": @"usToS" },
            @{ @"label": @"Second → Nanosecond", @"key": @"sToNs" },
            @{ @"label": @"Nanosecond → Second", @"key": @"nsToS" }
         ],
        @"Angle": @[
            @{ @"label": @"Degrees → Radians", @"key": @"degToRad" },
            @{ @"label": @"Radians → Degrees", @"key": @"radToDeg" },
            @{ @"label": @"Degrees → Arcminutes", @"key": @"degToArcmin" },
            @{ @"label": @"Arcminutes → Degrees", @"key": @"arcminToDeg" },
            @{ @"label": @"Degrees → Arcseconds", @"key": @"degToArcsec" },
            @{ @"label": @"Arcseconds → Degrees", @"key": @"arcsecToDeg" },
            @{ @"label": @"Radians → Milliradians", @"key": @"radToMrad" },
            @{ @"label": @"Milliradians → Radians", @"key": @"mradToRad" },
            @{ @"label": @"Arcseconds → Milliarcseconds", @"key": @"arcsecToMas" },
            @{ @"label": @"Milliarcseconds → Arcseconds", @"key": @"masToArcsec" },
            @{ @"label": @"Arcseconds → Microarcseconds", @"key": @"arcsecToUsas" },
            @{ @"label": @"Microarcseconds → Arcseconds", @"key": @"usasToArcsec" }
         ],
        @"Area": @[
            @{ @"label": @"Acre → m²", @"key": @"acreToM2" },
            @{ @"label": @"m² → Acre", @"key": @"m2ToAcre" },
            @{ @"label": @"Are → m²", @"key": @"areToM2" },
            @{ @"label": @"m² → Are", @"key": @"m2ToAre" },
            @{ @"label": @"Decare → m²", @"key": @"decareToM2" },
            @{ @"label": @"m² → Decare", @"key": @"m2ToDecare" },
            @{ @"label": @"Hectare → m²", @"key": @"hectareToM2" },
            @{ @"label": @"m² → Hectare", @"key": @"m2ToHectare" },
            @{ @"label": @"cm² → m²", @"key": @"cm2ToM2" },
            @{ @"label": @"m² → cm²", @"key": @"m2ToCm2" },
            @{ @"label": @"ft² → m²", @"key": @"ft2ToM2" },
            @{ @"label": @"m² → ft²", @"key": @"m2ToFt2" },
            @{ @"label": @"in² → m²", @"key": @"in2ToM2" },
            @{ @"label": @"m² → in²", @"key": @"m2ToIn2" },
            @{ @"label": @"km² → m²", @"key": @"km2ToM2" },
            @{ @"label": @"m² → km²", @"key": @"m2ToKm2" },
            @{ @"label": @"mile² → m²", @"key": @"mi2ToM2" },
            @{ @"label": @"m² → mile²", @"key": @"m2ToMi2" },
            @{ @"label": @"mm² → m²", @"key": @"mm2ToM2" },
            @{ @"label": @"m² → mm²", @"key": @"m2ToMm2" },
            @{ @"label": @"yd² → m²", @"key": @"yd2ToM2" },
            @{ @"label": @"m² → yd²", @"key": @"m2ToYd2" },
            @{ @"label": @"Stremma → m²", @"key": @"stremmaToM2" },
            @{ @"label": @"m² → Stremma", @"key": @"m2ToStremma" }
         ],
        @"Energy": @[
            @{ @"label": @"BTU → J", @"key": @"btuToJ" },
            @{ @"label": @"J → BTU", @"key": @"jToBtu" },
            @{ @"label": @"Calorie → J", @"key": @"calToJ" },
            @{ @"label": @"J → Calorie", @"key": @"jToCal" },
            @{ @"label": @"Erg → J", @"key": @"ergToJ" },
            @{ @"label": @"J → Erg", @"key": @"jToErg" },
            @{ @"label": @"Foot-pound → J", @"key": @"ftlbToJ" },
            @{ @"label": @"J → Foot-pound", @"key": @"jToFtlb" },
            @{ @"label": @"Kilocalorie → J", @"key": @"kcalToJ" },
            @{ @"label": @"J → Kilocalorie", @"key": @"jToKcal" },
            @{ @"label": @"Kilojoule → J", @"key": @"kjToJ" },
            @{ @"label": @"J → Kilojoule", @"key": @"jToKj" },
            @{ @"label": @"Kilowatt-hour → J", @"key": @"kwhToJ" },
            @{ @"label": @"J → Kilowatt-hour", @"key": @"jToKwh" },
            @{ @"label": @"Newton-meter → J", @"key": @"nmToJ" },
            @{ @"label": @"J → Newton-meter", @"key": @"jToNm" }
            
         ],
        @"Fuel": @[
            @{ @"label": @"Gallon/100mi → km/L", @"key": @"g100miToKmpl" },
            @{ @"label": @"km/L → Gallon/100mi", @"key": @"kmplToG100mi" },
            @{ @"label": @"L/100km → km/L", @"key": @"l100kmToKmpl" },
            @{ @"label": @"km/L → L/100km", @"key": @"kmplToL100km" },
            @{ @"label": @"MPG → km/L", @"key": @"mpgToKmpl" },
            @{ @"label": @"km/L → MPG", @"key": @"kmplToMpg" }
            
         ],
        @"Data": @[
            @{ @"label": @"Bit → Byte", @"key": @"bitToByte" },
            @{ @"label": @"Byte → Bit", @"key": @"byteToBit" },
            @{ @"label": @"KB → Byte", @"key": @"kbToByte" },
            @{ @"label": @"Byte → KB", @"key": @"byteToKb" },
            @{ @"label": @"KiB → Byte", @"key": @"kibToByte" },
            @{ @"label": @"Byte → KiB", @"key": @"byteToKib" },
            @{ @"label": @"MB → Byte", @"key": @"mbToByte" },
            @{ @"label": @"Byte → MB", @"key": @"byteToMb" },
            @{ @"label": @"MiB → Byte", @"key": @"mibToByte" },
            @{ @"label": @"Byte → MiB", @"key": @"byteToMib" },
            @{ @"label": @"GB → Byte", @"key": @"gbToByte" },
            @{ @"label": @"Byte → GB", @"key": @"byteToGb" },
            @{ @"label": @"GiB → Byte", @"key": @"gibToByte" },
            @{ @"label": @"Byte → GiB", @"key": @"byteToGib" },
            @{ @"label": @"TB → Byte", @"key": @"tbToByte" },
            @{ @"label": @"Byte → TB", @"key": @"byteToTb" },
            @{ @"label": @"TiB → Byte", @"key": @"tibToByte" },
            @{ @"label": @"Byte → TiB", @"key": @"byteToTib" },
            @{ @"label": @"PB → Byte", @"key": @"pbToByte" },
            @{ @"label": @"Byte → PB", @"key": @"byteToPb" },
            @{ @"label": @"PiB → Byte", @"key": @"pibToByte" },
            @{ @"label": @"Byte → PiB", @"key": @"byteToPib" }
         ],
        @"Force": @[
            @{ @"label": @"Dyne → Newton", @"key": @"dyneToN" },
            @{ @"label": @"Newton → Dyne", @"key": @"nToDyne" },
            @{ @"label": @"Kilogram-force → Newton", @"key": @"kgfToN" },
            @{ @"label": @"Newton → Kilogram-force", @"key": @"nToKgf" },
            @{ @"label": @"Pound-force → Newton", @"key": @"lbfToN" },
            @{ @"label": @"Newton → Pound-force", @"key": @"nToLbf" },
            @{ @"label": @"Poundal → Newton", @"key": @"pdlToN" },
            @{ @"label": @"Newton → Poundal", @"key": @"nToPdl" }
         ],
        @"Power": @[
            @{ @"label": @"BTU/min → Watt", @"key": @"btumToW" },
            @{ @"label": @"Watt → BTU/min", @"key": @"wToBtum" },
            @{ @"label": @"Horsepower → Watt", @"key": @"hpToW" },
            @{ @"label": @"Watt → Horsepower", @"key": @"wToHp" },
            @{ @"label": @"Kilowatt → Watt", @"key": @"kwToW" },
            @{ @"label": @"Watt → Kilowatt", @"key": @"wToKw" }
         ],
        @"Volume": @[
            @{ @"label": @"Bushel → Liter", @"key": @"bushelToL" },
            @{ @"label": @"Liter → Bushel", @"key": @"lToBushel" },
            @{ @"label": @"Cup → Milliliter", @"key": @"cupToMl" },
            @{ @"label": @"Milliliter → Cup", @"key": @"mlToCup" },
            @{ @"label": @"Cubic Meter → Liter", @"key": @"m3ToL" },
            @{ @"label": @"Liter → Cubic Meter", @"key": @"lToM3" },
            @{ @"label": @"Gallon → Liter", @"key": @"galToL" },
            @{ @"label": @"Liter → Gallon", @"key": @"lToGal" },
            @{ @"label": @"Teaspoon → Milliliter", @"key": @"tspToMl" },
            @{ @"label": @"Milliliter → Teaspoon", @"key": @"mlToTsp" },
            @{ @"label": @"Tablespoon → Milliliter", @"key": @"tbspToMl" },
            @{ @"label": @"Milliliter → Tablespoon", @"key": @"mlToTbsp" }
        ],
        @"Currency": @[
        @{ @"label": @"CAD → USD", @"key": @"CADToUSD" }
        ],
    };

    self.categories = categories;
    self.categoryKeys = [[categories allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    
    for (NSArray *group in [categories allValues]) {
        [all addObjectsFromArray:group];
    }

    self.allConversions = all;
    self.filteredResults = all;
    self.isSearching = NO;

    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor systemBackgroundColor];
    vc.view.frame = UIScreen.mainScreen.bounds;

    self.resultsTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.resultsTable.delegate = self;
    self.resultsTable.dataSource = self;
    [self.resultsTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.resultsTable.frame = vc.view.bounds;
    self.resultsTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [vc.view addSubview:self.resultsTable];

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"Search conversions...";
    vc.navigationItem.searchController = self.searchController;
    vc.navigationItem.title = @"Conversions";

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [rootVC presentViewController:nav animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.isActive) return self.filteredResults.count;
    NSString *key = self.categoryKeys[section];
    return ((NSArray *)self.categories[key]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSDictionary *item;
    if (self.searchController.isActive) {
        item = self.filteredResults[indexPath.row];
    } else {
        NSString *key = self.categoryKeys[indexPath.section];
        item = self.categories[key][indexPath.row];
    }
    cell.textLabel.text = item[@"label"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item;
    if (self.searchController.isActive) {
        item = self.filteredResults[indexPath.row];
    } else {
        NSString *key = self.categoryKeys[indexPath.section];
        item = self.categories[key][indexPath.row];
    }
    selectedConversion = item[@"key"];
    [self triggerConversion];
    UIViewController *presentingVC = tableView.window.rootViewController.presentedViewController;
    [presentingVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)triggerConversion {
    NSString *text = fallbackDisplayValue();
    if (!text || text.length == 0) text = @"—";
    NSString *converted = convertValue(text);

    if (conversionLabel) {
        conversionLabel.text = converted;
        conversionLabel.hidden = NO;
        [conversionLabel.superview bringSubviewToFront:conversionLabel];

        CGSize maxSize = CGSizeMake(320, 110);
        CGRect textRect = [converted boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: conversionLabel.font} context:nil];
        CGRect frame = conversionLabel.frame;
        frame.size.width = MAX(90, ceil(textRect.size.width));
        conversionLabel.frame = frame;
    }
}

@end

NSString *reversedConversionKey(NSString *key) {
    static NSDictionary *map;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = @{
            @"btuToJ": @"jToBtu", @"jToBtu": @"btuToJ",
            @"calToJ": @"jToCal", @"jToCal": @"calToJ",
            @"ergToJ": @"jToErg", @"jToErg": @"ergToJ",
            @"ftlbToJ": @"jToFtlb", @"jToFtlb": @"ftlbToJ",
            @"kcalToJ": @"jToKcal", @"jToKcal": @"kcalToJ",
            @"kjToJ": @"jToKj", @"jToKj": @"kjToJ",
            @"kwhToJ": @"jToKwh", @"jToKwh": @"kwhToJ",
            @"nmToJ": @"jToNm", @"jToNm": @"nmToJ",
            @"g100miToKmpl": @"kmplToG100mi", @"kmplToG100mi": @"g100miToKmpl",
            @"l100kmToKmpl": @"kmplToL100km", @"kmplToL100km": @"l100kmToKmpl",
            @"mpgToKmpl": @"kmplToMpg", @"kmplToMpg": @"mpgToKmpl",
            @"bushelToL": @"lToBushel", @"lToBushel": @"bushelToL",
            @"cupToMl": @"mlToCup", @"mlToCup": @"cupToMl",
            @"m3ToL": @"lToM3", @"lToM3": @"m3ToL",
            @"galToL": @"lToGal", @"lToGal": @"galToL",
            @"tspToMl": @"mlToTsp", @"mlToTsp": @"tspToMl",
            @"tbspToMl": @"mlToTbsp", @"mlToTbsp": @"tbspToMl",
            @"btumToW": @"wToBtum", @"wToBtum": @"btumToW",
            @"hpToW": @"wToHp", @"wToHp": @"hpToW",
            @"kwToW": @"wToKw", @"wToKw": @"kwToW"
        };
    });
    return map[key] ?: key;
}

NSString *convertValue(NSString *input) {
    NSString *clean = [[input stringByReplacingOccurrencesOfString:@"," withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    double val = [clean doubleValue];
    
    NSArray *parts = [selectedConversion componentsSeparatedByString:@"To"];
    
        NSString *from = parts[0];
        NSString *to = parts[1];
        
    if (from.length == 3 && to.length == 3 &&
    [[NSCharacterSet uppercaseLetterCharacterSet] isSupersetOfSet:[NSCharacterSet characterSetWithCharactersInString:from]] &&
    [[NSCharacterSet uppercaseLetterCharacterSet] isSupersetOfSet:[NSCharacterSet characterSetWithCharactersInString:to]]) {
        
    
            fetchLiveRate(from, to, ^(double rate) {
            double result = val * rate;
            dispatch_async(dispatch_get_main_queue(), ^{
                conversionLabel.text = [NSString stringWithFormat:@"%.2f %@", result, to];
            });
        });

        return clean;
    }
    
    if ([selectedConversion isEqualToString:@"paToPsi"]) return [NSString stringWithFormat:@"%.4f psi", val * 0.000145038];
    if ([selectedConversion isEqualToString:@"psiToPa"]) return [NSString stringWithFormat:@"%.2f Pa", val / 0.000145038];
    if ([selectedConversion isEqualToString:@"barToAtm"]) return [NSString stringWithFormat:@"%.4f atm", val * 0.986923];
    if ([selectedConversion isEqualToString:@"atmToBar"]) return [NSString stringWithFormat:@"%.2f bar", val / 0.986923];
    if ([selectedConversion isEqualToString:@"torrToPa"]) return [NSString stringWithFormat:@"%.2f Pa", val * 133.322];
    if ([selectedConversion isEqualToString:@"paToTorr"]) return [NSString stringWithFormat:@"%.2f Torr", val / 133.322];
    if ([selectedConversion isEqualToString:@"inhgToKpa"]) return [NSString stringWithFormat:@"%.2f kPa", val * 3.38639];
    if ([selectedConversion isEqualToString:@"kpaToInhg"]) return [NSString stringWithFormat:@"%.2f inHg", val / 3.38639];
    if ([selectedConversion isEqualToString:@"psiToBar"]) return [NSString stringWithFormat:@"%.4f bar", val * 0.0689476];
    if ([selectedConversion isEqualToString:@"barToPsi"]) return [NSString stringWithFormat:@"%.2f psi", val / 0.0689476];
    
    if ([selectedConversion isEqualToString:@"cToF"]) return [NSString stringWithFormat:@"%.2f °F", (val * 9.0/5.0) + 32];
    if ([selectedConversion isEqualToString:@"fToC"]) return [NSString stringWithFormat:@"%.2f °C", (val - 32) * 5.0/9.0];
    if ([selectedConversion isEqualToString:@"cToK"]) return [NSString stringWithFormat:@"%.2f K", val + 273.15];
    if ([selectedConversion isEqualToString:@"kToC"]) return [NSString stringWithFormat:@"%.2f °C", val - 273.15];
    if ([selectedConversion isEqualToString:@"fToK"]) return [NSString stringWithFormat:@"%.2f K", (val - 32) * 5.0/9.0 + 273.15];
    if ([selectedConversion isEqualToString:@"kToF"]) return [NSString stringWithFormat:@"%.2f °F", (val - 273.15) * 9.0/5.0 + 32];
    
    if ([selectedConversion isEqualToString:@"ftToM"]) return [NSString stringWithFormat:@"%.4f m", val * 0.3048];
    if ([selectedConversion isEqualToString:@"mToFt"]) return [NSString stringWithFormat:@"%.4f ft", val / 0.3048];
    if ([selectedConversion isEqualToString:@"inToCm"]) return [NSString stringWithFormat:@"%.4f cm", val * 2.54];
    if ([selectedConversion isEqualToString:@"cmToIn"]) return [NSString stringWithFormat:@"%.4f in", val / 2.54];
    if ([selectedConversion isEqualToString:@"miToKm"]) return [NSString stringWithFormat:@"%.4f km", val * 1.60934];
    if ([selectedConversion isEqualToString:@"kmToMi"]) return [NSString stringWithFormat:@"%.4f mi", val / 1.60934];
    if ([selectedConversion isEqualToString:@"ydToM"]) return [NSString stringWithFormat:@"%.4f m", val * 0.9144];
    if ([selectedConversion isEqualToString:@"mToYd"]) return [NSString stringWithFormat:@"%.4f yd", val / 0.9144];
    if ([selectedConversion isEqualToString:@"mmToIn"]) return [NSString stringWithFormat:@"%.4f in", val / 25.4];
    if ([selectedConversion isEqualToString:@"inToMm"]) return [NSString stringWithFormat:@"%.4f mm", val * 25.4];
    if ([selectedConversion isEqualToString:@"dmToM"]) return [NSString stringWithFormat:@"%.4f m", val * 0.1];
    if ([selectedConversion isEqualToString:@"mToDm"]) return [NSString stringWithFormat:@"%.4f dm", val / 0.1];
    if ([selectedConversion isEqualToString:@"lyToKm"]) return [NSString stringWithFormat:@"%.4f km", val * 9.461e+12];
    if ([selectedConversion isEqualToString:@"kmToLy"]) return [NSString stringWithFormat:@"%.10f ly", val / 9.461e+12];
    if ([selectedConversion isEqualToString:@"pcToLy"]) return [NSString stringWithFormat:@"%.4f ly", val * 3.26156];
    if ([selectedConversion isEqualToString:@"lyToPc"]) return [NSString stringWithFormat:@"%.4f pc", val / 3.26156];
    if ([selectedConversion isEqualToString:@"nmToKm"]) return [NSString stringWithFormat:@"%.4f km", val * 1.852];
    if ([selectedConversion isEqualToString:@"kmToNm"]) return [NSString stringWithFormat:@"%.4f NM", val / 1.852];
    if ([selectedConversion isEqualToString:@"auToKm"]) return [NSString stringWithFormat:@"%.4f km", val * 1.496e+8];
    if ([selectedConversion isEqualToString:@"kmToAu"]) return [NSString stringWithFormat:@"%.10f AU", val / 1.496e+8];
    
    if ([selectedConversion isEqualToString:@"mpsToKph"]) return [NSString stringWithFormat:@"%.4f km/h", val * 3.6];
    if ([selectedConversion isEqualToString:@"kphToMps"]) return [NSString stringWithFormat:@"%.4f m/s", val / 3.6];
    if ([selectedConversion isEqualToString:@"fpsToMps"]) return [NSString stringWithFormat:@"%.4f m/s", val * 0.3048];
    if ([selectedConversion isEqualToString:@"mpsToFps"]) return [NSString stringWithFormat:@"%.4f ft/s", val / 0.3048];
    if ([selectedConversion isEqualToString:@"mphToKph"]) return [NSString stringWithFormat:@"%.4f km/h", val * 1.60934];
    if ([selectedConversion isEqualToString:@"kphToMph"]) return [NSString stringWithFormat:@"%.4f mph", val / 1.60934];
    if ([selectedConversion isEqualToString:@"knotToKph"]) return [NSString stringWithFormat:@"%.4f km/h", val * 1.852];
    if ([selectedConversion isEqualToString:@"kphToKnot"]) return [NSString stringWithFormat:@"%.4f kn", val / 1.852];
    
    if ([selectedConversion isEqualToString:@"dramToG"]) return [NSString stringWithFormat:@"%.4f g", val * 1.7718451953125];
    if ([selectedConversion isEqualToString:@"gToDram"]) return [NSString stringWithFormat:@"%.4f dram", val / 1.7718451953125];
    if ([selectedConversion isEqualToString:@"kgToLb"]) return [NSString stringWithFormat:@"%.4f lb", val * 2.20462];
    if ([selectedConversion isEqualToString:@"lbToKg"]) return [NSString stringWithFormat:@"%.4f kg", val / 2.20462];
    if ([selectedConversion isEqualToString:@"ozToG"]) return [NSString stringWithFormat:@"%.4f g", val * 28.3495];
    if ([selectedConversion isEqualToString:@"gToOz"]) return [NSString stringWithFormat:@"%.4f oz", val / 28.3495];
    if ([selectedConversion isEqualToString:@"mgToG"]) return [NSString stringWithFormat:@"%.4f g", val / 1000];
    if ([selectedConversion isEqualToString:@"gToMg"]) return [NSString stringWithFormat:@"%.4f mg", val * 1000];
    if ([selectedConversion isEqualToString:@"stToKg"]) return [NSString stringWithFormat:@"%.4f kg", val * 6.35029];
    if ([selectedConversion isEqualToString:@"kgToSt"]) return [NSString stringWithFormat:@"%.4f st", val / 6.35029];
    if ([selectedConversion isEqualToString:@"tonToKg"]) return [NSString stringWithFormat:@"%.4f kg", val * 907.18474];
    if ([selectedConversion isEqualToString:@"kgToTon"]) return [NSString stringWithFormat:@"%.4f ton", val / 907.18474];
    if ([selectedConversion isEqualToString:@"tToKg"]) return [NSString stringWithFormat:@"%.4f kg", val * 1000];
    if ([selectedConversion isEqualToString:@"kgToT"]) return [NSString stringWithFormat:@"%.4f t", val / 1000];
    if ([selectedConversion isEqualToString:@"longTonToKg"]) return [NSString stringWithFormat:@"%.4f kg", val * 1016.0469088];
    if ([selectedConversion isEqualToString:@"kgToLongTon"]) return [NSString stringWithFormat:@"%.4f long ton", val / 1016.0469088];
    if ([selectedConversion isEqualToString:@"slugToKg"]) return [NSString stringWithFormat:@"%.4f kg", val * 14.5939];
    if ([selectedConversion isEqualToString:@"kgToSlug"]) return [NSString stringWithFormat:@"%.4f slug", val / 14.5939];
    if ([selectedConversion isEqualToString:@"tozToG"]) return [NSString stringWithFormat:@"%.4f g", val * 31.1034768];
    if ([selectedConversion isEqualToString:@"gToToz"]) return [NSString stringWithFormat:@"%.4f toz", val / 31.1034768];
    
    if ([selectedConversion isEqualToString:@"sToMs"]) return [NSString stringWithFormat:@"%.2f ms", val * 1000];
    if ([selectedConversion isEqualToString:@"msToS"]) return [NSString stringWithFormat:@"%.4f s", val / 1000];
    if ([selectedConversion isEqualToString:@"minToS"]) return [NSString stringWithFormat:@"%.2f s", val * 60];
    if ([selectedConversion isEqualToString:@"sToMin"]) return [NSString stringWithFormat:@"%.4f min", val / 60];
    if ([selectedConversion isEqualToString:@"hrToMin"]) return [NSString stringWithFormat:@"%.2f min", val * 60];
    if ([selectedConversion isEqualToString:@"minToHr"]) return [NSString stringWithFormat:@"%.4f hr", val / 60];
    if ([selectedConversion isEqualToString:@"dayToHr"]) return [NSString stringWithFormat:@"%.2f hr", val * 24];
    if ([selectedConversion isEqualToString:@"hrToDay"]) return [NSString stringWithFormat:@"%.4f day", val / 24];
    if ([selectedConversion isEqualToString:@"wkToDay"]) return [NSString stringWithFormat:@"%.2f day", val * 7];
    if ([selectedConversion isEqualToString:@"dayToWk"]) return [NSString stringWithFormat:@"%.4f wk", val / 7];
    if ([selectedConversion isEqualToString:@"yrToDay"]) return [NSString stringWithFormat:@"%.2f day", val * 365];
    if ([selectedConversion isEqualToString:@"dayToYr"]) return [NSString stringWithFormat:@"%.4f yr", val / 365];
    if ([selectedConversion isEqualToString:@"sToUs"]) return [NSString stringWithFormat:@"%.2f μs", val * 1e6];
    if ([selectedConversion isEqualToString:@"usToS"]) return [NSString stringWithFormat:@"%.6f s", val / 1e6];
    if ([selectedConversion isEqualToString:@"sToNs"]) return [NSString stringWithFormat:@"%.2f ns", val * 1e9];
    if ([selectedConversion isEqualToString:@"nsToS"]) return [NSString stringWithFormat:@"%.8f s", val / 1e9];
    
    if ([selectedConversion isEqualToString:@"degToRad"]) return [NSString stringWithFormat:@"%.6f rad", val * M_PI / 180];
    if ([selectedConversion isEqualToString:@"radToDeg"]) return [NSString stringWithFormat:@"%.4f°", val * 180 / M_PI];
    if ([selectedConversion isEqualToString:@"degToArcmin"]) return [NSString stringWithFormat:@"%.2f arcmin", val * 60];
    if ([selectedConversion isEqualToString:@"arcminToDeg"]) return [NSString stringWithFormat:@"%.4f°", val / 60];
    if ([selectedConversion isEqualToString:@"degToArcsec"]) return [NSString stringWithFormat:@"%.2f arcsec", val * 3600];
    if ([selectedConversion isEqualToString:@"arcsecToDeg"]) return [NSString stringWithFormat:@"%.6f°", val / 3600];
    if ([selectedConversion isEqualToString:@"radToMrad"]) return [NSString stringWithFormat:@"%.2f mrad", val * 1000];
    if ([selectedConversion isEqualToString:@"mradToRad"]) return [NSString stringWithFormat:@"%.6f rad", val / 1000];
    if ([selectedConversion isEqualToString:@"arcsecToMas"]) return [NSString stringWithFormat:@"%.2f mas", val * 1000];
    if ([selectedConversion isEqualToString:@"masToArcsec"]) return [NSString stringWithFormat:@"%.4f arcsec", val / 1000];
    if ([selectedConversion isEqualToString:@"arcsecToUsas"]) return [NSString stringWithFormat:@"%.2f μas", val * 1e6];
    if ([selectedConversion isEqualToString:@"usasToArcsec"]) return [NSString stringWithFormat:@"%.8f arcsec", val / 1e6];
    
    if ([selectedConversion isEqualToString:@"acreToM2"]) return [NSString stringWithFormat:@"%.4f m²", val * 4046.85642];
    if ([selectedConversion isEqualToString:@"m2ToAcre"]) return [NSString stringWithFormat:@"%.4f Acre", val / 4046.85642];
    if ([selectedConversion isEqualToString:@"areToM2"]) return [NSString stringWithFormat:@"%.4f m²", val * 100];
    if ([selectedConversion isEqualToString:@"m2ToAre"]) return [NSString stringWithFormat:@"%.4f Are", val / 100];
    if ([selectedConversion isEqualToString:@"decareToM2"]) return [NSString stringWithFormat:@"%.4f m²", val * 1000];
    if ([selectedConversion isEqualToString:@"m2ToDecare"]) return [NSString stringWithFormat:@"%.4f Decare", val / 1000];
    if ([selectedConversion isEqualToString:@"hectareToM2"]) return [NSString stringWithFormat:@"%.4f m²", val * 10000];
    if ([selectedConversion isEqualToString:@"m2ToHectare"]) return [NSString stringWithFormat:@"%.4f Hectare", val / 10000];
    if ([selectedConversion isEqualToString:@"cm2ToM2"]) return [NSString stringWithFormat:@"%.4f m²", val * 0.0001];
    if ([selectedConversion isEqualToString:@"m2ToCm2"]) return [NSString stringWithFormat:@"%.4f cm²", val * 10000];
    if ([selectedConversion isEqualToString:@"ft2ToM2"]) return [NSString stringWithFormat:@"%.4f m²", val * 0.09290304];
    if ([selectedConversion isEqualToString:@"m2ToFt2"]) return [NSString stringWithFormat:@"%.4f ft²", val / 0.09290304];
    if ([selectedConversion isEqualToString:@"in2ToM2"]) return [NSString stringWithFormat:@"%.4f m²", val * 0.00064516];
    if ([selectedConversion isEqualToString:@"m2ToIn2"]) return [NSString stringWithFormat:@"%.4f in²", val / 0.00064516];
    if ([selectedConversion isEqualToString:@"km2ToM2"]) return [NSString stringWithFormat:@"%.4f m²", val * 1e6];
    if ([selectedConversion isEqualToString:@"m2ToKm2"]) return [NSString stringWithFormat:@"%.6f km²", val / 1e6];
    if ([selectedConversion isEqualToString:@"mi2ToM2"]) return [NSString stringWithFormat:@"%.4f m²", val * 2589988.110336];
    if ([selectedConversion isEqualToString:@"m2ToMi2"]) return [NSString stringWithFormat:@"%.6f mile²", val / 2589988.110336];
    if ([selectedConversion isEqualToString:@"mm2ToM2"]) return [NSString stringWithFormat:@"%.6f m²", val * 0.000001];
    if ([selectedConversion isEqualToString:@"m2ToMm2"]) return [NSString stringWithFormat:@"%.2f mm²", val * 1000000];
    if ([selectedConversion isEqualToString:@"yd2ToM2"]) return [NSString stringWithFormat:@"%.4f m²", val * 0.83612736];
    if ([selectedConversion isEqualToString:@"m2ToYd2"]) return [NSString stringWithFormat:@"%.4f yd²", val / 0.83612736];
    if ([selectedConversion isEqualToString:@"stremmaToM2"]) return [NSString stringWithFormat:@"%.4f m²", val * 1000];
    if ([selectedConversion isEqualToString:@"m2ToStremma"]) return [NSString stringWithFormat:@"%.4f Stremma", val / 1000];
    
    if ([selectedConversion isEqualToString:@"btuToJ"]) return [NSString stringWithFormat:@"%.2f J", val * 1055.06];
    if ([selectedConversion isEqualToString:@"jToBtu"]) return [NSString stringWithFormat:@"%.4f BTU", val / 1055.06];
    if ([selectedConversion isEqualToString:@"calToJ"]) return [NSString stringWithFormat:@"%.2f J", val * 4.184];
    if ([selectedConversion isEqualToString:@"jToCal"]) return [NSString stringWithFormat:@"%.4f cal", val / 4.184];
    if ([selectedConversion isEqualToString:@"ergToJ"]) return [NSString stringWithFormat:@"%.6f J", val * 1e-7];
    if ([selectedConversion isEqualToString:@"jToErg"]) return [NSString stringWithFormat:@"%.2f erg", val / 1e-7];
    if ([selectedConversion isEqualToString:@"ftlbToJ"]) return [NSString stringWithFormat:@"%.4f J", val * 1.35582];
    if ([selectedConversion isEqualToString:@"jToFtlb"]) return [NSString stringWithFormat:@"%.4f ft·lb", val / 1.35582];
    if ([selectedConversion isEqualToString:@"kcalToJ"]) return [NSString stringWithFormat:@"%.2f J", val * 4184];
    if ([selectedConversion isEqualToString:@"jToKcal"]) return [NSString stringWithFormat:@"%.4f kcal", val / 4184];
    if ([selectedConversion isEqualToString:@"kjToJ"]) return [NSString stringWithFormat:@"%.2f J", val * 1000];
    if ([selectedConversion isEqualToString:@"jToKj"]) return [NSString stringWithFormat:@"%.4f kJ", val / 1000];
    if ([selectedConversion isEqualToString:@"kwhToJ"]) return [NSString stringWithFormat:@"%.2f J", val * 3.6e6];
    if ([selectedConversion isEqualToString:@"jToKwh"]) return [NSString stringWithFormat:@"%.6f kWh", val / 3.6e6];
    if ([selectedConversion isEqualToString:@"nmToJ"]) return [NSString stringWithFormat:@"%.2f J", val];
    if ([selectedConversion isEqualToString:@"jToNm"]) return [NSString stringWithFormat:@"%.2f Nm", val];
    
    if ([selectedConversion isEqualToString:@"g100miToKmpl"]) return [NSString stringWithFormat:@"%.2f km/L", 235.214583 / val];
    if ([selectedConversion isEqualToString:@"kmplToG100mi"]) return [NSString stringWithFormat:@"%.2f gal/100mi", 235.214583 / val];
    if ([selectedConversion isEqualToString:@"l100kmToKmpl"]) return [NSString stringWithFormat:@"%.2f km/L", 100.0 / val];
    if ([selectedConversion isEqualToString:@"kmplToL100km"]) return [NSString stringWithFormat:@"%.2f L/100km", 100.0 / val];
    if ([selectedConversion isEqualToString:@"mpgToKmpl"]) return [NSString stringWithFormat:@"%.2f km/L", val * 0.425144];
    if ([selectedConversion isEqualToString:@"kmplToMpg"]) return [NSString stringWithFormat:@"%.2f MPG", val / 0.425144];
    
    if ([selectedConversion isEqualToString:@"bitToByte"]) return [NSString stringWithFormat:@"%.2f B", val / 8.0];
    if ([selectedConversion isEqualToString:@"byteToBit"]) return [NSString stringWithFormat:@"%.0f b", val * 8.0];
    if ([selectedConversion isEqualToString:@"kbToByte"]) return [NSString stringWithFormat:@"%.0f B", val * 1000];
    if ([selectedConversion isEqualToString:@"byteToKb"]) return [NSString stringWithFormat:@"%.2f KB", val / 1000.0];
    if ([selectedConversion isEqualToString:@"kibToByte"]) return [NSString stringWithFormat:@"%.0f B", val * 1024];
    if ([selectedConversion isEqualToString:@"byteToKib"]) return [NSString stringWithFormat:@"%.2f KiB", val / 1024.0];
    if ([selectedConversion isEqualToString:@"mbToByte"]) return [NSString stringWithFormat:@"%.0f B", val * 1e6];
    if ([selectedConversion isEqualToString:@"byteToMb"]) return [NSString stringWithFormat:@"%.2f MB", val / 1e6];
    if ([selectedConversion isEqualToString:@"mibToByte"]) return [NSString stringWithFormat:@"%.0f B", val * 1048576];
    if ([selectedConversion isEqualToString:@"byteToMib"]) return [NSString stringWithFormat:@"%.2f MiB", val / 1048576.0];
    if ([selectedConversion isEqualToString:@"gbToByte"]) return [NSString stringWithFormat:@"%.0f B", val * 1e9];
    if ([selectedConversion isEqualToString:@"byteToGb"]) return [NSString stringWithFormat:@"%.2f GB", val / 1e9];
    if ([selectedConversion isEqualToString:@"gibToByte"]) return [NSString stringWithFormat:@"%.0f B", val * 1073741824];
    if ([selectedConversion isEqualToString:@"byteToGib"]) return [NSString stringWithFormat:@"%.2f GiB", val / 1073741824.0];
    if ([selectedConversion isEqualToString:@"tbToByte"]) return [NSString stringWithFormat:@"%.0f B", val * 1e12];
    if ([selectedConversion isEqualToString:@"byteToTb"]) return [NSString stringWithFormat:@"%.2f TB", val / 1e12];
    if ([selectedConversion isEqualToString:@"tibToByte"]) return [NSString stringWithFormat:@"%.0f B", val * 1099511627776];
    if ([selectedConversion isEqualToString:@"byteToTib"]) return [NSString stringWithFormat:@"%.2f TiB", val / 1099511627776.0];
    if ([selectedConversion isEqualToString:@"pbToByte"]) return [NSString stringWithFormat:@"%.0f B", val * 1e15];
    if ([selectedConversion isEqualToString:@"byteToPb"]) return [NSString stringWithFormat:@"%.2f PB", val / 1e15];
    if ([selectedConversion isEqualToString:@"pibToByte"]) return [NSString stringWithFormat:@"%.0f B", val * 1125899906842624];
    if ([selectedConversion isEqualToString:@"byteToPib"]) return [NSString stringWithFormat:@"%.2f PiB", val / 1125899906842624.0];
    
    if ([selectedConversion isEqualToString:@"dyneToN"]) return [NSString stringWithFormat:@"%.8f N", val * 1e-5];
    if ([selectedConversion isEqualToString:@"nToDyne"]) return [NSString stringWithFormat:@"%.2f dyn", val / 1e-5];
    if ([selectedConversion isEqualToString:@"kgfToN"]) return [NSString stringWithFormat:@"%.4f N", val * 9.80665];
    if ([selectedConversion isEqualToString:@"nToKgf"]) return [NSString stringWithFormat:@"%.4f kgf", val / 9.80665];
    if ([selectedConversion isEqualToString:@"lbfToN"]) return [NSString stringWithFormat:@"%.4f N", val * 4.44822];
    if ([selectedConversion isEqualToString:@"nToLbf"]) return [NSString stringWithFormat:@"%.4f lbf", val / 4.44822];
    if ([selectedConversion isEqualToString:@"pdlToN"]) return [NSString stringWithFormat:@"%.6f N", val * 0.138255];
    if ([selectedConversion isEqualToString:@"nToPdl"]) return [NSString stringWithFormat:@"%.4f pdl", val / 0.138255];
    
    if ([selectedConversion isEqualToString:@"btumToW"]) return [NSString stringWithFormat:@"%.2f W", val * 17.584266];
    if ([selectedConversion isEqualToString:@"wToBtum"]) return [NSString stringWithFormat:@"%.4f BTU/min", val / 17.584266];
    if ([selectedConversion isEqualToString:@"hpToW"]) return [NSString stringWithFormat:@"%.2f W", val * 745.7];
    if ([selectedConversion isEqualToString:@"wToHp"]) return [NSString stringWithFormat:@"%.4f HP", val / 745.7];
    if ([selectedConversion isEqualToString:@"kwToW"]) return [NSString stringWithFormat:@"%.2f W", val * 1000];
    if ([selectedConversion isEqualToString:@"wToKw"]) return [NSString stringWithFormat:@"%.4f kW", val / 1000.0];
    
    if ([selectedConversion isEqualToString:@"bushelToL"]) return [NSString stringWithFormat:@"%.2f L", val * 35.2391];
    if ([selectedConversion isEqualToString:@"lToBushel"]) return [NSString stringWithFormat:@"%.4f bushel", val / 35.2391];
    if ([selectedConversion isEqualToString:@"cupToMl"]) return [NSString stringWithFormat:@"%.2f mL", val * 236.588];
    if ([selectedConversion isEqualToString:@"mlToCup"]) return [NSString stringWithFormat:@"%.4f cup", val / 236.588];
    if ([selectedConversion isEqualToString:@"m3ToL"]) return [NSString stringWithFormat:@"%.2f L", val * 1000];
    if ([selectedConversion isEqualToString:@"lToM3"]) return [NSString stringWithFormat:@"%.4f m³", val / 1000];
    if ([selectedConversion isEqualToString:@"galToL"]) return [NSString stringWithFormat:@"%.2f L", val * 3.78541];
    if ([selectedConversion isEqualToString:@"lToGal"]) return [NSString stringWithFormat:@"%.4f gal", val / 3.78541];
    if ([selectedConversion isEqualToString:@"tspToMl"]) return [NSString stringWithFormat:@"%.2f mL", val * 4.92892];
    if ([selectedConversion isEqualToString:@"mlToTsp"]) return [NSString stringWithFormat:@"%.4f tsp", val / 4.92892];
    if ([selectedConversion isEqualToString:@"tbspToMl"]) return [NSString stringWithFormat:@"%.2f mL", val * 14.7868];
    if ([selectedConversion isEqualToString:@"mlToTbsp"]) return [NSString stringWithFormat:@"%.4f tbsp", val / 14.7868];
    
    return @"N/A";
}

NSString *fallbackDisplayValue() {
    UIWindowScene *scene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
    UIWindow *window = scene.windows.firstObject;
    for (UIView *subview in window.rootViewController.view.subviews) {
        if ([NSStringFromClass(subview.class) containsString:@"DisplayView"]) {
            for (UIView *label in subview.subviews) {
                if ([label isKindOfClass:[UILabel class]]) {
                    UILabel *disp = (UILabel *)label;
                    if (disp.text.length > 0) return disp.text;
                }
            }
        }
    }
    return @"N/A";
    }
    
__attribute__((constructor)) static void tweakInit() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindowScene *scene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
        UIWindow *window = scene.windows.firstObject;
        UIView *root = window.rootViewController.view;

        if (!conversionLabel) {
            conversionLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 60, 90, 110)];
            conversionLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.08];
            conversionLabel.textColor = [UIColor whiteColor];
            conversionLabel.textAlignment = NSTextAlignmentRight;
            conversionLabel.numberOfLines = 1;
            conversionLabel.font = [UIFont systemFontOfSize:34 weight:UIFontWeightMedium];
            conversionLabel.hidden = YES;
            conversionLabel.layer.cornerRadius = 16;
            conversionLabel.layer.masksToBounds = YES;
            [root addSubview:conversionLabel];
            
          UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:[ConversionHelper new]
            action:@selector(reverseConversion)];
            doubleTap.numberOfTapsRequired = 2;
            [conversionLabel addGestureRecognizer:doubleTap];
            conversionLabel.userInteractionEnabled = YES;
            
}

    if (!menuButton) {
        menuButton = [UIButton buttonWithType:UIButtonTypeSystem];
        menuButton.frame = CGRectMake(115, 709, 44, 44);
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:22 weight:UIImageSymbolWeightBold];
        UIImage *icon = [UIImage systemImageNamed:@"arrow.left.arrow.right.circle" withConfiguration:config];
        [menuButton setImage:icon forState:UIControlStateNormal];
        menuButton.tintColor = [UIColor whiteColor];
    
            ConversionHelper *helper = [ConversionHelper new];
            [menuButton addTarget:helper action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
            objc_setAssociatedObject(menuButton, "_helper", helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [root addSubview:menuButton];
        }
        
        if (!reverseButton) {
            reverseButton = [UIButton buttonWithType:UIButtonTypeSystem];
            reverseButton.frame = CGRectMake(223.333, 13, 155.333, 127.333);
            [reverseButton setTitle:@"🔄" forState:UIControlStateNormal];
            [reverseButton.titleLabel setFont:[UIFont systemFontOfSize:32 weight:UIFontWeightBold]];
            [reverseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            ConversionHelper *helper = [ConversionHelper new];
            [reverseButton addTarget:helper action:@selector(reverseConversion) forControlEvents:UIControlEventTouchUpInside];
            [root addSubview:reverseButton];
        }

        [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer *timer) {
            if (selectedConversion != nil) {
                [(ConversionHelper *)objc_getAssociatedObject(menuButton, "_helper") triggerConversion];
            }
        }];

        NSLog(@"[CalcConv] UI and Timer Injected");
    });
}

void fetchLiveRate(NSString *from, NSString *to, void (^completion)(double rate)) {
    NSString *urlString = [NSString stringWithFormat:@"https://api.exchangerate.host/convert?from=%@&to=%@", from, to];
    NSURL *url = [NSURL URLWithString:urlString];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (data && !error) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSNumber *rate = json[@"info"][@"rate"];
                if (rate) {
                    completion([rate doubleValue]);
                    return;
                }
            }
            completion(1.0); // fallback
    }];
    [task resume];
}


