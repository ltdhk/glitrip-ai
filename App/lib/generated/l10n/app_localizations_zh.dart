// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '轻松旅行';

  @override
  String get tagline => '合理规划，轻松出发';

  @override
  String get destinations => '目的地';

  @override
  String get documents => '文档';

  @override
  String get packing => '物品';

  @override
  String get profile => '我的';

  @override
  String get travel => '旅行';

  @override
  String get travelDocuments => '旅行文档';

  @override
  String get myProfile => '我的资料';

  @override
  String get searchDestinations => '搜索目的地...';

  @override
  String get searchDocuments => '搜索文档...';

  @override
  String get all => '全部';

  @override
  String get visited => '已去过';

  @override
  String get planned => '计划中';

  @override
  String get wishlist => '愿望清单';

  @override
  String get noDestinationsYet => '暂无目的地';

  @override
  String get startPlanningNextAdventure => '开始规划您的下一次冒险吧！';

  @override
  String get addFirstDestination => '添加第一个目的地';

  @override
  String get addDestination => '添加目的地';

  @override
  String get editDestination => '编辑目的地';

  @override
  String get newDestination => '新目的地';

  @override
  String get planYourNextAdventure => '规划您的下一次冒险';

  @override
  String get basicInformation => '基本信息';

  @override
  String get destinationName => '目的地名称';

  @override
  String get country => '国家';

  @override
  String get description => '描述';

  @override
  String get travelDetails => '旅行详情';

  @override
  String get status => '状态';

  @override
  String get budgetLevel => '预算级别';

  @override
  String get estimatedCost => '预估费用';

  @override
  String recommendedDays(int days) {
    return '建议$days天';
  }

  @override
  String get bestTimeToVisit => '最佳旅行时间';

  @override
  String get bestTimeExample => '例如：4月-6月';

  @override
  String get startDate => '开始日期';

  @override
  String get endDate => '结束日期';

  @override
  String get tags => '标签';

  @override
  String get addTagAndPressReturn => '添加标签并按回车';

  @override
  String get notes => '备注';

  @override
  String get travelNotes => '旅行笔记';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get retry => '重试';

  @override
  String get pleaseEnterDestinationName => '请输入目的地名称';

  @override
  String get pleaseEnterCountry => '请输入国家';

  @override
  String get pleaseEnterValidCost => '请输入有效的费用';

  @override
  String get startDateMustBeBeforeEndDate => '开始日期必须早于结束日期';

  @override
  String destinationsTotal(int count) {
    return '$count个目的地';
  }

  @override
  String get noDocumentsYet => '暂无文档';

  @override
  String get addTravelDocuments => '添加您的旅行文档，如护照、\n签证、机票和预订，以保持其井然有序';

  @override
  String get addFirstDocument => '添加第一个文档';

  @override
  String get addDocumentsDescription => '添加您的旅行文档，如护照、\n签证、机票和预订，以保持其井然有序';

  @override
  String get addDocument => '添加文档';

  @override
  String get editDocument => '编辑文档';

  @override
  String get documentInformation => '文档信息';

  @override
  String get documentName => '文档名称';

  @override
  String get documentType => '文档类型';

  @override
  String get hasExpiryDate => '有过期日期';

  @override
  String get expiryDate => '过期日期';

  @override
  String get selectExpiryDate => '选择过期日期';

  @override
  String get pleaseEnterDocumentName => '请输入文档名称';

  @override
  String get pleaseSelectExpiryDate => '请选择过期日期';

  @override
  String get addNotesAboutDocument => '添加关于此文档的备注...';

  @override
  String documentsTotal(int count) {
    return '$count个文档';
  }

  @override
  String get passport => '护照';

  @override
  String get idCard => '身份证';

  @override
  String get visa => '签证';

  @override
  String get insurance => '保险';

  @override
  String get ticket => '机票';

  @override
  String get hotel => '酒店预订';

  @override
  String get hotelBooking => '酒店预订';

  @override
  String get carRental => '租车';

  @override
  String get other => '其他';

  @override
  String get noExpiry => '无过期日期';

  @override
  String get expiresSoon => '即将过期';

  @override
  String get hasNotes => '有备注';

  @override
  String get created => '创建时间';

  @override
  String get attachedImages => '附件图片';

  @override
  String get noImagesAttached => '无附件图片';

  @override
  String imageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count张图片',
      one: '1张图片',
      zero: '无图片',
    );
    return '$_temp0';
  }

  @override
  String get deleteDocument => '删除文档';

  @override
  String deleteDocumentConfirm(String name) {
    return '确定要删除\"$name\"吗？此操作无法撤销。';
  }

  @override
  String get documentDeleted => '文档删除成功';

  @override
  String noDocumentsOfType(String type) {
    return '暂无$type';
  }

  @override
  String get addDocumentsToGetStarted => '添加一些文档开始使用吧！';

  @override
  String get images => '图片';

  @override
  String get takePhoto => '拍照';

  @override
  String get choosePhoto => '选择照片';

  @override
  String errorPickingImage(Object error) {
    return '选择图片时出错：$error';
  }

  @override
  String get packingProgress => '打包进度';

  @override
  String get completed => '完成';

  @override
  String get clothing => '服装';

  @override
  String get electronics => '电子产品';

  @override
  String get cosmetics => '化妆品';

  @override
  String get health => '药品';

  @override
  String get accessories => '配饰';

  @override
  String get books => '书籍';

  @override
  String get entertainment => '娱乐';

  @override
  String packingTotal(int total) {
    return '共$total项物品';
  }

  @override
  String noItemsInCategory(String category) {
    return '暂无$category物品';
  }

  @override
  String get addItemsToGetStarted => '添加一些物品开始使用吧！';

  @override
  String get noPackingItemsYet => '暂无打包物品';

  @override
  String get startAddingItemsToPackingList => '开始添加物品到您的打包清单';

  @override
  String get addFirstItem => '添加第一个物品';

  @override
  String get addPackingItem => '添加打包物品';

  @override
  String get editPackingItem => '编辑打包物品';

  @override
  String get itemDetails => '物品详情';

  @override
  String get selectDestination => '选择目的地';

  @override
  String get itemName => '物品名称';

  @override
  String get pleaseEnterItemName => '请输入物品名称';

  @override
  String get category => '类别';

  @override
  String get quantity => '数量';

  @override
  String get essentialItem => '必需品';

  @override
  String get noDestinationsAvailable => '没有可用的目的地';

  @override
  String get errorLoadingDestinations => '加载目的地时出错';

  @override
  String get pleaseSelectDestination => '请选择目的地';

  @override
  String get itemAddedSuccessfully => '物品添加成功';

  @override
  String get itemUpdatedSuccessfully => '物品更新成功';

  @override
  String errorSavingItem(Object error) {
    return '保存物品时出错：$error';
  }

  @override
  String get travelExplorer => '旅行家';

  @override
  String get adventureAwaits => '新的冒险等待着！';

  @override
  String get travelStatistics => '旅行统计';

  @override
  String get total => '总数';

  @override
  String get quickActions => '快捷操作';

  @override
  String get addTravelBuddy => '添加旅伴';

  @override
  String get travelBuddies => '旅伴';

  @override
  String get noTravelBuddiesYet => '暂无旅伴';

  @override
  String get addTravelBuddyLink => '添加旅伴';

  @override
  String selectedTravelBuddies(Object count) {
    return '已选择 $count 位旅伴';
  }

  @override
  String loadingTravelBuddiesFailed(Object error) {
    return '加载旅伴失败: $error';
  }

  @override
  String get noTravelBuddyInfo => '暂无旅伴信息';

  @override
  String get findSomeoneToTravelWith => '找个人一起旅行';

  @override
  String get dontForgetEssentials => '不要忘记必需品';

  @override
  String get overview => '总览';

  @override
  String get budget => '预算';

  @override
  String get itinerary => '行程';

  @override
  String get memories => '回忆';

  @override
  String get budgetOverview => '预算概览';

  @override
  String get tapToManageExpenses => '点击管理支出';

  @override
  String get spent => '已花费';

  @override
  String get deleteDestination => '删除目的地';

  @override
  String deleteDestinationConfirm(String name) {
    return '确定要删除\"$name\"吗？此操作无法撤销。';
  }

  @override
  String get deleteItem => '删除物品';

  @override
  String deleteItemConfirm(String name) {
    return '确定要删除\"$name\"吗？';
  }

  @override
  String errorSavingDestination(Object error) {
    return '保存目的地时出错：$error';
  }

  @override
  String errorSavingDocument(Object error) {
    return '保存文档时出错：$error';
  }

  @override
  String noSearchResults(String query) {
    return '没有找到匹配\"$query\"的结果';
  }

  @override
  String searchError(Object error) {
    return '搜索出错：$error';
  }

  @override
  String get errorLoadingProfile => '加载资料时出错';

  @override
  String get featureInDevelopment => '功能开发中...';

  @override
  String itemsTotal(int count) {
    return '共$count个物品';
  }

  @override
  String get name => '姓名';

  @override
  String get email => '邮箱';

  @override
  String get phone => '电话';

  @override
  String get availability => '可出行时间 (例如：2024年6月)';

  @override
  String get confirmedToTravel => '确认出行';

  @override
  String get travelPreferences => '旅行偏好';

  @override
  String get adventure => '冒险';

  @override
  String get relaxation => '休闲';

  @override
  String get culture => '文化';

  @override
  String get foodie => '美食';

  @override
  String get nature => '自然';

  @override
  String get urban => '城市';

  @override
  String get dreamDestinations => '梦想目的地';

  @override
  String get addDestinationAndPressReturn => '添加目的地并按回车';

  @override
  String get pleaseEnterName => '请输入姓名';

  @override
  String get pleaseEnterEmail => '请输入邮箱';

  @override
  String get pleaseEnterPhone => '请输入电话';

  @override
  String get travelBuddyAddedSuccessfully => '旅伴添加成功';

  @override
  String get travelBuddyUpdatedSuccessfully => '旅伴更新成功';

  @override
  String errorSavingTravelBuddy(Object error) {
    return '保存旅伴时出错：$error';
  }

  @override
  String get editTravelBuddy => '编辑旅伴';

  @override
  String get deleteTravelBuddy => '删除旅伴';

  @override
  String deleteTravelBuddyConfirm(String name) {
    return '确定要删除\"$name\"吗？此操作无法撤销。';
  }

  @override
  String get travelBuddyDeleted => '旅伴删除成功';

  @override
  String get addTravelBuddiesToGetStarted => '添加一些旅伴开始使用吧！';

  @override
  String get addFirstTravelBuddy => '添加第一个旅伴';

  @override
  String travelBuddiesTotal(int count) {
    return '共$count个旅伴';
  }

  @override
  String get searchTravelBuddies => '搜索旅伴...';

  @override
  String get low => '低';

  @override
  String get medium => '中';

  @override
  String get high => '高';

  @override
  String get budgetLevelCard => '预算级别';

  @override
  String get comfort => '舒适';

  @override
  String get luxury => '奢华';

  @override
  String get budgetOption => '经济';

  @override
  String get budgetAndExpenses => '预算与支出';

  @override
  String get totalBudget => '总预算';

  @override
  String get remaining => '剩余';

  @override
  String get used => '已使用';

  @override
  String get expensesByCategory => '分类支出';

  @override
  String get recentExpenses => '最近支出';

  @override
  String get noExpensesYet => '暂无支出';

  @override
  String get addFirstExpenseToStartTracking => '添加您的第一笔支出开始记录';

  @override
  String get addExpense => '添加支出';

  @override
  String get editExpense => '编辑支出';

  @override
  String get expenseDetails => '支出详情';

  @override
  String get expenseName => '支出名称';

  @override
  String get amount => '金额';

  @override
  String get date => '日期';

  @override
  String get alreadyPaid => '已支付';

  @override
  String get accommodation => '住宿';

  @override
  String get transport => '交通';

  @override
  String get food => '餐饮';

  @override
  String get activities => '活动';

  @override
  String get shopping => '购物';

  @override
  String get paid => '已付款';

  @override
  String get unpaid => '未付款';

  @override
  String get noItineraryYet => '暂无行程';

  @override
  String get planYourTripDayByDay => '逐日规划您的旅行';

  @override
  String get addFirstDay => '添加第一天';

  @override
  String get addItineraryDay => '添加行程日';

  @override
  String get editItineraryDay => '编辑行程日';

  @override
  String get dayInformation => '日期信息';

  @override
  String get dayTitle => '日期标题';

  @override
  String day(int number) {
    return '第$number天';
  }

  @override
  String get addActivity => '添加活动';

  @override
  String get time => '时间';

  @override
  String get activityTitle => '活动标题';

  @override
  String get location => '位置';

  @override
  String get cost => '费用';

  @override
  String get costOptional => '费用（可选）';

  @override
  String get alreadyBooked => '已预订';

  @override
  String get noActivitiesPlanned => '暂无活动安排';

  @override
  String get deleteDay => '删除日期';

  @override
  String deleteDayConfirm(String title) {
    return '确定要删除\"$title\"吗？';
  }

  @override
  String get dayDeletedSuccessfully => '日期删除成功';

  @override
  String get timeExample => '时间（例如：9:00 AM）';

  @override
  String days(int count) {
    return '$count天';
  }

  @override
  String get packingList => '打包清单';

  @override
  String get progress => '进度';

  @override
  String get noItemsYet => '暂无物品';

  @override
  String get addItemsToPackingList => '将物品添加到打包清单';

  @override
  String get essential => '必需品';

  @override
  String get itemDeletedSuccessfully => '物品删除成功';

  @override
  String get travelMemories => '旅行回忆';

  @override
  String get noMemoriesYet => '暂无回忆';

  @override
  String get addPhotosAndStories => '添加您旅行中的照片和故事';

  @override
  String get addFirstMemory => '添加第一个回忆';

  @override
  String get addMemory => '添加回忆';

  @override
  String get editMemory => '编辑回忆';

  @override
  String get deleteMemory => '删除回忆';

  @override
  String deleteMemoryConfirm(String title) {
    return '确定要删除\"$title\"吗？';
  }

  @override
  String get memoryDeletedSuccessfully => '回忆删除成功';

  @override
  String get memoryDetails => '回忆详情';

  @override
  String get memoryTitle => '回忆标题';

  @override
  String get rating => '评分';

  @override
  String get shareYourExperience => '分享您的体验...';

  @override
  String get items => '项目';

  @override
  String get currentTrips => '当前行程';

  @override
  String get templates => '模板';

  @override
  String get history => '历史记录';

  @override
  String get viewDetails => '查看详情';

  @override
  String get addItems => '添加物品';

  @override
  String get noCurrentTrips => '暂无当前行程';

  @override
  String get planTripToStartPacking => '规划行程开始打包';

  @override
  String get noTemplatesYet => '暂无模板';

  @override
  String get createTemplateToReuse => '创建模板以重复使用物品';

  @override
  String get noCompletedTrips => '还没有已完成的旅行';

  @override
  String get completedTripsWillAppearHere => '已完成的行程将显示在这里';

  @override
  String get pleaseEnterExpenseName => '请输入支出名称';

  @override
  String get pleaseEnterAmount => '请输入金额';

  @override
  String get expenseAddedSuccessfully => '支出添加成功';

  @override
  String get expenseUpdatedSuccessfully => '支出更新成功';

  @override
  String errorSavingExpense(Object error) {
    return '保存支出时出错：$error';
  }

  @override
  String get deleteExpense => '删除支出';

  @override
  String deleteExpenseConfirm(String name) {
    return '确定要删除\"$name\"吗？此操作无法撤销。';
  }

  @override
  String get viewPacking => '查看打包';

  @override
  String get addFromTemplate => '从模板添加';

  @override
  String get addFromTemplateDescription => '从模板中选择物品快速添加到打包清单';

  @override
  String get selectFromTemplate => '从模板选择';

  @override
  String get addSelected => '添加选中';

  @override
  String get errorLoadingItems => '加载物品时出错';

  @override
  String get errorLoadingStats => '加载统计时出错';

  @override
  String get errorLoadingTemplates => '加载模板时出错';

  @override
  String get totalItems => '总物品';

  @override
  String get packed => '已打包';

  @override
  String get selectAllTemplateItems => '选择所有模板物品';

  @override
  String get createTemplateFirst => '请先创建模板';

  @override
  String get pleaseSelectItems => '请选择物品';

  @override
  String get addingItems => '正在添加物品...';

  @override
  String get creatingTemplateItem => '正在创建模板物品';

  @override
  String get addToDestination => '添加到目的地';

  @override
  String get addItemToSpecificDestination => '添加物品到特定目的地';

  @override
  String get addToTemplate => '添加到模板';

  @override
  String get addItemToTemplate => '添加物品到模板';

  @override
  String get deleteTemplateItem => '删除模板物品';

  @override
  String deleteTemplateItemConfirm(String name) {
    return '确定要删除模板物品\"$name\"吗？';
  }

  @override
  String get templateItemDeletedSuccessfully => '模板物品删除成功';

  @override
  String get featureComingSoon => '功能即将推出';

  @override
  String get select => '选择';

  @override
  String errorDeletingItem(Object error) {
    return '删除物品时出错：$error';
  }

  @override
  String itemsAddedSuccessfully(int count) {
    return '成功添加$count个物品';
  }

  @override
  String errorAddingItems(Object error) {
    return '添加物品时出错：$error';
  }

  @override
  String get aiSmartCreateDestination => 'AI智能创建目的地';

  @override
  String get aiPlanPreview => 'AI规划预览';

  @override
  String get letAiPlanYourTrip => '让AI帮您规划旅行';

  @override
  String get fourStepsAutoGenerate => '只需4步，AI自动生成完整行程';

  @override
  String get aiPlanning => 'AI正在为您规划行程...';

  @override
  String get aiPlanningTime => '这可能需要10-30秒';

  @override
  String get pleaseSelectTravelDates => '请选择出行日期';

  @override
  String get aiFailed => 'AI生成失败';

  @override
  String remainingAiPlans(int count) {
    return '剩余 $count 次AI规划';
  }

  @override
  String get aiQuotaExhausted => 'AI规划次数已用尽，请升级VIP';

  @override
  String get destinationNameLabel => '1. 目的地名称';

  @override
  String get destinationNameHint => '例如：东京、巴黎、纽约...';

  @override
  String get budgetLevelLabel => '2. 预算级别';

  @override
  String get budgetEconomy => '经济';

  @override
  String get budgetComfort => '舒适';

  @override
  String get budgetLuxury => '奢华';

  @override
  String get travelDatesLabel => '3. 出行日期';

  @override
  String get startDateLabel => '开始日期';

  @override
  String get endDateLabel => '结束日期';

  @override
  String get selectDate => '选择日期';

  @override
  String get aiSmartPlanButton => '4. AI智能规划';

  @override
  String get aiAutoDetectCountry => '* AI将自动识别目的地所在国家并生成详细的旅行计划';

  @override
  String get planGeneratedSuccessfully => '规划生成成功！';

  @override
  String get savePlan => '保存计划';

  @override
  String get savingPlan => '正在保存...';

  @override
  String get planSavedSuccess => '计划保存成功！';

  @override
  String dayNumberLabel(int number) {
    return '第$number天';
  }

  @override
  String get packagedItems => '打包物品';

  @override
  String get todoItems => '待办事项';

  @override
  String get detailedItinerary => '详细行程';

  @override
  String get aiGeneratedPlan => 'AI生成的旅行计划';

  @override
  String daysCount(int count) {
    return '$count天';
  }

  @override
  String itemsCount(int count) {
    return '$count 项';
  }

  @override
  String get categoryClothing => '衣物';

  @override
  String get categoryElectronics => '电子产品';

  @override
  String get categoryCosmetics => '洗护用品';

  @override
  String get categoryHealth => '健康用品';

  @override
  String get categoryAccessories => '配件';

  @override
  String get categoryBooks => '书籍';

  @override
  String get categoryEntertainment => '娱乐';

  @override
  String get categoryOther => '其他';

  @override
  String get currencySymbol => '¥';

  @override
  String get currencyCode => 'CNY';

  @override
  String get todos => '待办';

  @override
  String get currentTodoTrips => '当前行程';

  @override
  String get completedTodos => '已完成';

  @override
  String get allTodos => '全部';

  @override
  String get todoCategoryPassport => '护照';

  @override
  String get todoCategoryIdCard => '身份证';

  @override
  String get todoCategoryVisa => '签证';

  @override
  String get todoCategoryInsurance => '保险';

  @override
  String get todoCategoryTicket => '机票';

  @override
  String get todoCategoryHotel => '酒店预订';

  @override
  String get todoCategoryCarRental => '租车';

  @override
  String get todoCategoryOther => '其他';

  @override
  String get todoDetails => '待办明细';

  @override
  String get todoStats => '统计';

  @override
  String get totalTodos => '总数';

  @override
  String get completedCount => '已完成';

  @override
  String get pendingCount => '未完成';

  @override
  String get highPriorityCount => '高优先级';

  @override
  String get byCategory => '按类别';

  @override
  String get addTodo => '添加待办';

  @override
  String get editTodo => '编辑待办';

  @override
  String get todoTitle => '标题';

  @override
  String get todoCategory => '类别';

  @override
  String get selectCategory => '选择类别';

  @override
  String get todoDescription => '描述';

  @override
  String get todoPriority => '优先级';

  @override
  String get todoDeadline => '截止时间';

  @override
  String get priorityHigh => '高';

  @override
  String get priorityMedium => '中';

  @override
  String get priorityLow => '低';

  @override
  String get markAsComplete => '标记为完成';

  @override
  String get markAsIncomplete => '标记为未完成';

  @override
  String get deleteTodo => '删除待办';

  @override
  String get todoDeleteConfirm => '确定删除此待办事项？';

  @override
  String get noTodosYet => '还没有待办事项';

  @override
  String get noTodosInCategory => '此类别暂无待办事项';

  @override
  String get addFirstTodo => '添加第一个待办事项';

  @override
  String get todoTitleRequired => '请输入标题';

  @override
  String get todoCategoryRequired => '请选择类别';

  @override
  String get selectDeadline => '选择截止时间';

  @override
  String get clearDeadline => '清除截止时间';

  @override
  String get overdue => '已逾期';

  @override
  String get dueToday => '今天截止';

  @override
  String get dueSoon => '即将截止';

  @override
  String get optional => '可选';

  @override
  String get updateSuccess => '更新成功';

  @override
  String get addSuccess => '添加成功';

  @override
  String get error => '错误';

  @override
  String get deleteSuccess => '删除成功';

  @override
  String get noPlannedDestinations => '还没有计划中的目的地';

  @override
  String get createDestinationPrompt => '创建您的第一个旅行计划吧！';

  @override
  String get completeFirstTrip => '完成您的第一次旅行吧！';

  @override
  String get noDestinations => '还没有目的地';

  @override
  String get createFirstDestination => '开始规划您的旅行吧！';
}
