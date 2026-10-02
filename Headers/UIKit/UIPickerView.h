#ifndef GNUSTEP_UIKIT_UIPICKERVIEW_H
#define GNUSTEP_UIKIT_UIPICKERVIEW_H
#import <UIKit/UIView.h>
@class UIPickerView;
@protocol UIPickerViewDataSource <NSObject>
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
@end
@protocol UIPickerViewDelegate <NSObject>
@optional
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
@end
@interface UIPickerView : UIView
{ id<UIPickerViewDataSource> _dataSource; id<UIPickerViewDelegate> _delegate; NSMutableArray *_components; }
@property(nonatomic, assign) id<UIPickerViewDataSource> dataSource;
@property(nonatomic, assign) id<UIPickerViewDelegate> delegate;
@property(nonatomic, readonly) NSInteger numberOfComponents;
- (NSInteger)numberOfRowsInComponent:(NSInteger)component;
- (void)reloadAllComponents;
- (void)reloadComponent:(NSInteger)component;
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated;
- (NSInteger)selectedRowInComponent:(NSInteger)component;
@end
#endif
