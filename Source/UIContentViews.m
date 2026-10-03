#import "UIKitPrivate.h"
@interface _UIKitListContentView : UIView <UIContentView> { UIListContentConfiguration *_configuration; UILabel *_title, *_subtitle; UIImageView *_image; }
@end
@implementation _UIKitListContentView
- (id)initWithFrame:(CGRect)frame {
  self=[super initWithFrame:frame]; if(self) { _title=[UILabel new]; _subtitle=[UILabel new]; _image=[UIImageView new];
    _title.numberOfLines=0; _subtitle.numberOfLines=0; _subtitle.font=[UIFont systemFontOfSize:14];
    _subtitle.textColor=[UIColor secondaryLabelColor]; _image.contentMode=UIViewContentModeScaleAspectFit;
    [self addSubview:_image]; [self addSubview:_title]; [self addSubview:_subtitle]; } return self;
}
- (void)dealloc { [_configuration release]; [_title release]; [_subtitle release]; [_image release]; [super dealloc]; }
- (id<UIContentConfiguration>)configuration { return _configuration; }
- (void)setConfiguration:(id<UIContentConfiguration>)configuration {
  ASSIGNCOPY(_configuration,(UIListContentConfiguration *)configuration); _title.text=_configuration.text; _subtitle.text=_configuration.secondaryText; _image.image=_configuration.image;
  [self invalidateIntrinsicContentSize]; [self setNeedsLayout];
}
- (void)layoutSubviews {
  [super layoutSubviews]; CGFloat left=_image.image ? 60 : 12, width=MAX(0,self.bounds.size.width-left-12);
  CGFloat title=[_title sizeThatFits:CGSizeMake(width,10000)].height, subtitle=[_subtitle sizeThatFits:CGSizeMake(width,10000)].height;
  CGFloat top=MAX(8,(self.bounds.size.height-title-subtitle-4)/2);
  _title.frame=CGRectMake(left,top,width,title); _subtitle.frame=CGRectMake(left,top+title+4,width,subtitle);
  _image.frame=CGRectMake(12,MAX(0,(self.bounds.size.height-36)/2),36,36);
}
- (CGSize)intrinsicContentSize { return CGSizeMake(UIViewNoIntrinsicMetric,80); }
@end
@implementation UIListContentConfiguration
@synthesize text=_text, secondaryText=_secondaryText, image=_image;
+ (instancetype)cellConfiguration { return [[[self alloc] init] autorelease]; }
+ (instancetype)subtitleCellConfiguration { return [self cellConfiguration]; }
+ (instancetype)plainHeaderConfiguration { return [self cellConfiguration]; }
- (void)dealloc { [_text release]; [_secondaryText release]; [_image release]; [super dealloc]; }
- (id)copyWithZone:(NSZone *)zone { UIListContentConfiguration *copy=[[[self class] allocWithZone:zone] init]; copy.text=_text; copy.secondaryText=_secondaryText; copy.image=_image; return copy; }
- (id<UIContentConfiguration>)updatedConfigurationForState:(id)state { return [[self copy] autorelease]; }
- (UIView *)makeContentView { _UIKitListContentView *view=[[[_UIKitListContentView alloc] init] autorelease]; view.configuration=self; return view; }
@end
@implementation UIContentUnavailableConfiguration
+ (instancetype)emptyConfiguration { return [self cellConfiguration]; }
+ (instancetype)searchConfiguration { UIContentUnavailableConfiguration *c=[self emptyConfiguration]; c.text=@"No Results"; c.secondaryText=@"Try another search."; return c; }
+ (instancetype)loadingConfiguration { UIContentUnavailableConfiguration *c=[self emptyConfiguration]; c.text=@"Loading…"; return c; }
@end
@implementation UIContentUnavailableView
@synthesize scrollEnabled=_scrollEnabled;
- (id)initWithConfiguration:(UIContentUnavailableConfiguration *)configuration { self=[super initWithFrame:CGRectZero]; if(self) self.configuration=configuration; return self; }
- (void)dealloc { [_configuration release]; [super dealloc]; }
- (id<UIContentConfiguration>)configuration { return _configuration; }
- (void)setConfiguration:(id<UIContentConfiguration>)configuration { ASSIGNCOPY(_configuration,configuration); [_configuredView removeFromSuperview]; _configuredView=[configuration makeContentView]; if (_configuredView) [self addSubview:_configuredView]; [self setNeedsLayout]; }
- (void)layoutSubviews { [super layoutSubviews]; _configuredView.frame=self.bounds; }
- (CGSize)intrinsicContentSize { return CGSizeMake(UIViewNoIntrinsicMetric,140); }
@end
@implementation UICollectionViewListCell
- (void)dealloc { [_contentConfiguration release]; [super dealloc]; }
- (UIListContentConfiguration *)defaultContentConfiguration { return [UIListContentConfiguration cellConfiguration]; }
- (id<UIContentConfiguration>)contentConfiguration { return _contentConfiguration; }
- (void)setContentConfiguration:(id<UIContentConfiguration>)configuration { ASSIGNCOPY(_contentConfiguration,configuration); [_configuredView removeFromSuperview]; _configuredView=[configuration makeContentView]; if(_configuredView) [self.contentView addSubview:_configuredView]; [self setNeedsLayout]; }
- (void)layoutSubviews { [super layoutSubviews]; _configuredView.frame=self.contentView.bounds; }
@end
@implementation UITableViewHeaderFooterView
- (id)initWithReuseIdentifier:(NSString *)identifier { self=[super initWithFrame:CGRectZero]; if(self) { _reuseIdentifier=[identifier copy]; _contentView=[UIView new]; _textLabel=[UILabel new]; _detailTextLabel=[UILabel new]; _detailTextLabel.font=[UIFont systemFontOfSize:13]; [self addSubview:_contentView]; [_contentView addSubview:_textLabel]; [_contentView addSubview:_detailTextLabel]; } return self; }
- (id)initWithFrame:(CGRect)frame { self=[self initWithReuseIdentifier:nil]; if(self) self.frame=frame; return self; }
- (void)dealloc { [_contentView release]; [_textLabel release]; [_detailTextLabel release]; [_reuseIdentifier release]; [super dealloc]; }
@synthesize contentView=_contentView, textLabel=_textLabel, detailTextLabel=_detailTextLabel, reuseIdentifier=_reuseIdentifier;
- (void)layoutSubviews { [super layoutSubviews]; _contentView.frame=self.bounds; _textLabel.frame=CGRectMake(12,8,MAX(0,self.bounds.size.width-24),24); _detailTextLabel.frame=CGRectMake(12,34,MAX(0,self.bounds.size.width-24),24); }
- (CGSize)intrinsicContentSize { return CGSizeMake(UIViewNoIntrinsicMetric,66); }
- (void)prepareForReuse {}
@end