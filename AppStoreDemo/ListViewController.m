#import "ListViewController.h"
#import "ListTableViewCell.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

@interface ListViewController () <UIGestureRecognizerDelegate>
{
    IBOutlet UITableView *tbl_list;
    IBOutlet UIView *view_detail;
    IBOutlet UIImageView *img_main;
    
    CGRect lastRect;
    NSIndexPath *lastIndexPath;
    CGPoint initialTouchPoint;
    float radius;
}
@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tbl_list.rowHeight = 250;
    img_main.layer.cornerRadius = 20;
    
    initialTouchPoint = CGPointMake(0, 40);
    radius = 0.0;
    
    //add swipe down animation
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [view_detail addGestureRecognizer:panRecognizer];
}

#pragma mark - PAN GESTURE METHOD
-(void)move:(UIPanGestureRecognizer*)sender {
    CGPoint touchPoint = [sender translationInView:sender.view.superview];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        radius = 0;
        initialTouchPoint = touchPoint;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        if (touchPoint.y - initialTouchPoint.y > 0) {
            if(radius < 20)
                radius = radius + 1;
            
            [UIView animateWithDuration:0.50
                             animations:^{
                                 self->img_main.layer.cornerRadius = self->radius;
                             }
                             completion:^(BOOL finished){
                             }];
            if(touchPoint.y - initialTouchPoint.y > 40)
                view_detail.frame = CGRectMake(0, touchPoint.y - initialTouchPoint.y, view_detail.frame.size.width, view_detail.frame.size.height);
        }
    } else if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        if (touchPoint.y - initialTouchPoint.y > 100) {
            //dissmiss
            [self clk_close:nil];
        } else {
            [UIView animateWithDuration:0.50
                             animations:^{
                                 CGRect frame = self->view_detail.frame;
                                 // adjust size of frame to desired value
                                 frame.size.height = SCREEN_HEIGHT - 40;
                                 frame.size.width = SCREEN_WIDTH;
                                 frame.origin.x = 0;
                                 frame.origin.y = 40;
                                 self->view_detail.frame = frame;
                                 self->img_main.layer.cornerRadius = 0;
                                 [self->view_detail layoutIfNeeded];
                             }
                             completion:^(BOOL finished){
                             }];
        }
    }
}

#pragma mark - CLICK EVENTS
-(IBAction)clk_close:(id)sender
{
    [UIView animateWithDuration:0.50
                     animations:^{
                         self->view_detail.frame = self->lastRect;
                         self->img_main.layer.cornerRadius = 20;
                         [self->view_detail layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                         
                         [self->view_detail removeFromSuperview];
                         
                         [UIView animateWithDuration:0.3 animations:^{
                             [self->tbl_list cellForRowAtIndexPath:self->lastIndexPath].transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                         } completion:^(BOOL finished) {
                         }];
                     }];
}

#pragma mark - UITableView delegat
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListTableViewCell *cell = (ListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ListTableViewCell"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ListTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.cell_img.layer.cornerRadius = 20;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //custom animation for open view event
    [UIView animateWithDuration:0.3 animations:^{
        [tableView cellForRowAtIndexPath:indexPath].transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 0.95);
    } completion:^(BOOL finished) {
        CGRect rectInTableView = [tableView rectForRowAtIndexPath:indexPath];
        CGRect rectInSuperview = [tableView convertRect:rectInTableView toView:[tableView superview]];
        self->lastRect = rectInSuperview;
        self->lastIndexPath = indexPath;
        self->view_detail.frame = rectInSuperview;
        
        [self.view addSubview:self->view_detail];
        
        [self->view_detail layoutIfNeeded];
        
        [UIView animateWithDuration:0.50
                         animations:^{
                             CGRect frame = self->view_detail.frame;
                             // adjust size of frame to desired value
                             frame.size.height = SCREEN_HEIGHT - 40;
                             frame.size.width = SCREEN_WIDTH;
                             frame.origin.x = 0;
                             frame.origin.y = 40;
                             self->view_detail.frame = frame;
                             self->img_main.layer.cornerRadius = 0;
                             [self->view_detail layoutIfNeeded];
                         }
                         completion:^(BOOL finished){
                         }];
    }];
     
    
}
@end
