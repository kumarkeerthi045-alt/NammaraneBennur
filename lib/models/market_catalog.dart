class MarketItem {
  const MarketItem(this.id, this.category, this.name, this.emoji, this.price, this.unit);
  final String id;
  final String category;
  final String name;
  final String emoji;
  final double price;
  final String unit;

  MarketItem copyWith({String? name, String? category, String? emoji, double? price, String? unit}) =>
      MarketItem(id, category ?? this.category, name ?? this.name, emoji ?? this.emoji, price ?? this.price, unit ?? this.unit);
}

const marketCategories = <String>[
  'Vegetables', 'Fruits', 'Groceries', 'Snacks', 'Meat & Eggs', 'Stationery',
  'Dairy & Breakfast', 'Drinks', 'Personal Care', 'Cleaning Essentials',
  'Baby & Pet Care', 'Bakery',
];

const starterMarketItems = <MarketItem>[
  MarketItem('tomato','Vegetables','Tomato','🍅',40,'1 kg'), MarketItem('onion','Vegetables','Onion','🧅',35,'1 kg'),
  MarketItem('potato','Vegetables','Potato','🥔',40,'1 kg'), MarketItem('carrot','Vegetables','Carrot','🥕',60,'1 kg'),
  MarketItem('brinjal','Vegetables','Brinjal','🍆',50,'1 kg'), MarketItem('cucumber','Vegetables','Cucumber','🥒',45,'1 kg'),
  MarketItem('chilli','Vegetables','Green chilli','🌶️',100,'1 kg'), MarketItem('spinach','Vegetables','Leafy spinach','🥬',80,'1 kg'),
  MarketItem('apple','Fruits','Apple','🍎',200,'1 kg'), MarketItem('banana','Fruits','Banana','🍌',60,'1 kg'),
  MarketItem('orange','Fruits','Orange','🍊',100,'1 kg'), MarketItem('grapes','Fruits','Grapes','🍇',120,'1 kg'),
  MarketItem('pomegranate','Fruits','Pomegranate','🔴',180,'1 kg'), MarketItem('papaya','Fruits','Papaya','🧡',60,'1 kg'),
  MarketItem('watermelon','Fruits','Watermelon','🍉',40,'1 kg'), MarketItem('mango','Fruits','Mango','🥭',150,'1 kg'),
  MarketItem('rice','Groceries','Rice','🍚',60,'1 kg'), MarketItem('atta','Groceries','Wheat flour / Atta','🌾',55,'1 kg'),
  MarketItem('dal','Groceries','Toor dal','🫘',140,'1 kg'), MarketItem('sugar','Groceries','Sugar','🧂',50,'1 kg'),
  MarketItem('salt','Groceries','Salt','🧂',25,'1 packet'), MarketItem('oil','Groceries','Cooking oil','🫗',150,'1 litre'),
  MarketItem('tea','Groceries','Tea','🍵',120,'250 g'), MarketItem('spices','Groceries','Indian spices','🌶️',45,'100 g'),
  MarketItem('chips','Snacks','Potato chips','🍟',20,'1 packet'), MarketItem('biscuits','Snacks','Biscuits','🍪',30,'1 packet'),
  MarketItem('mixture','Snacks','Namkeen mixture','🥨',50,'1 packet'), MarketItem('noodles','Snacks','Instant noodles','🍜',20,'1 packet'),
  MarketItem('chocolate','Snacks','Chocolate','🍫',40,'1 packet'), MarketItem('juice','Snacks','Fruit juice','🧃',50,'1 packet'),
  MarketItem('bread','Snacks','Bread','🍞',45,'1 packet'), MarketItem('rusk','Snacks','Rusk biscuits','🥖',60,'1 packet'),
  MarketItem('chicken','Meat & Eggs','Chicken','🍗',280,'1 kg'), MarketItem('mutton','Meat & Eggs','Mutton','🥩',900,'1 kg'),
  MarketItem('eggs','Meat & Eggs','Eggs','🥚',42,'6 pieces'), MarketItem('fish','Meat & Eggs','Fresh fish','🐟',260,'1 kg'),
  MarketItem('liver','Meat & Eggs','Chicken liver','🍖',220,'1 kg'), MarketItem('prawns','Meat & Eggs','Prawns','🦐',450,'1 kg'),
  MarketItem('sausages','Meat & Eggs','Chicken sausages','🌭',180,'1 packet'), MarketItem('paneer','Meat & Eggs','Paneer','🧀',360,'1 kg'),
  MarketItem('notebook','Stationery','Notebook','📒',50,'1 piece'), MarketItem('pens','Stationery','Ballpoint pens','🖊️',10,'1 piece'),
  MarketItem('pencils','Stationery','Pencils','✏️',8,'1 piece'), MarketItem('eraser','Stationery','Eraser','🧽',10,'1 piece'),
  MarketItem('sharpener','Stationery','Sharpener','🔷',15,'1 piece'), MarketItem('ruler','Stationery','Ruler','📏',20,'1 piece'),
  MarketItem('crayons','Stationery','Crayons','🖍️',80,'1 piece'), MarketItem('glue','Stationery','Glue','🧴',40,'1 piece'),
  MarketItem('milk','Dairy & Breakfast','Toned milk','🥛',28,'500 ml'), MarketItem('curd','Dairy & Breakfast','Curd','🥣',38,'400 g'),
  MarketItem('butter','Dairy & Breakfast','Butter','🧈',58,'100 g'), MarketItem('breakfast-paneer','Dairy & Breakfast','Fresh paneer','🧀',90,'200 g'),
  MarketItem('water','Drinks','Packaged water','💧',20,'1 litre'), MarketItem('mango-drink','Drinks','Mango fruit drink','🥭',100,'1 litre'),
  MarketItem('soda','Drinks','Soda bottle','🥤',22,'300 ml'), MarketItem('soap','Personal Care','Bathing soap','🧼',40,'100 g'),
  MarketItem('toothpaste','Personal Care','Toothpaste','🪥',95,'150 g'), MarketItem('detergent','Cleaning Essentials','Detergent powder','🫧',125,'1 kg'),
  MarketItem('floor-cleaner','Cleaning Essentials','Floor cleaner','🧴',105,'1 litre'), MarketItem('diapers','Baby & Pet Care','Baby diapers','👶',280,'10 pieces'),
  MarketItem('dog-food','Baby & Pet Care','Dog food','🐕',350,'1 kg'), MarketItem('bun-pack','Bakery','Bun pack','🍞',35,'6 pieces'),
  MarketItem('cake-slice','Bakery','Cake slice','🍰',40,'150 g'),
];
