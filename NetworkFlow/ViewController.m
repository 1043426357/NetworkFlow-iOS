//
//  ViewController.m
//  NetworkFlow
//
//  Created by 新闻 on 15-3-9.
//  Copyright (c) 2015年 Adways. All rights reserved.
//

#import "ViewController.h"

#import "AppDelegate.h"

#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <net/if_dl.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkNetworkflow) userInfo:nil repeats:YES];
    
}

-(NSString *)bytesToAvaiUnit:(int)bytes
{
    if(bytes < 1024)     // B
    {
        return [NSString stringWithFormat:@"%dB", bytes];
    }
    else if(bytes >= 1024 && bytes < 1024 * 1024) // KB
    {
        return [NSString stringWithFormat:@"%.1fKB", (double)bytes / 1024];
    }
    else if(bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024)   // MB
    {
        return [NSString stringWithFormat:@"%.2fMB", (double)bytes / (1024 * 1024)];
    }
    else    // GB
    {
        return [NSString stringWithFormat:@"%.3fGB", (double)bytes / (1024 * 1024 * 1024)];
    }
}
-(void)checkNetworkflow
{
    struct ifaddrs *ifa_list = 0, *ifa;
    if (getifaddrs(&ifa_list) == -1)
    {
        return ;
    }
    
    uint32_t iBytes     = 0;
    uint32_t oBytes     = 0;
    uint32_t allFlow    = 0;
    uint32_t wifiIBytes = 0;
    uint32_t wifiOBytes = 0;
    uint32_t wifiFlow   = 0;
    uint32_t wwanIBytes = 0;
    uint32_t wwanOBytes = 0;
    uint32_t wwanFlow   = 0;
//    struct timeval time ;
    struct timeval32 time;
    
    for (ifa = ifa_list; ifa; ifa = ifa->ifa_next)
    {
        if (AF_LINK != ifa->ifa_addr->sa_family)
            continue;
        
        if (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
            continue;
        
        if (ifa->ifa_data == 0)
            continue;
        
        // Not a loopback device.
        // network flow
        if (strncmp(ifa->ifa_name, "lo", 2))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            iBytes += if_data->ifi_ibytes;
            oBytes += if_data->ifi_obytes;
            allFlow = iBytes + oBytes;
            time = if_data->ifi_lastchange;
        }
        
        //wifi flow
        if (!strcmp(ifa->ifa_name, "en0"))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            wifiIBytes += if_data->ifi_ibytes;
            wifiOBytes += if_data->ifi_obytes;
            wifiFlow    = wifiIBytes + wifiOBytes;
        }
        
        //3G and gprs flow
        if (!strcmp(ifa->ifa_name, "pdp_ip0"))
        {
            struct if_data *if_data = (struct if_data *)ifa->ifa_data;
            
            wwanIBytes += if_data->ifi_ibytes;
            wwanOBytes += if_data->ifi_obytes;
            wwanFlow    = wwanIBytes + wwanOBytes;
        }
    }
    freeifaddrs(ifa_list);
    
    NSString *changeTime=[NSString stringWithFormat:@"%s",ctime(&time)];
    
//    NSLog(@"changeTime==%@",changeTime);
//    NSString *receivedBytes= [self bytesToAvaiUnit:iBytes];
//    
//    NSLog(@"receivedBytes==%@",receivedBytes);
//    NSString *sentBytes       = [self bytesToAvaiUnit:oBytes];
//    
//    NSLog(@"sentBytes==%@",sentBytes);
//    NSString *networkFlow      = [self bytesToAvaiUnit:allFlow];
//    
//    NSLog(@"networkFlow==%@",networkFlow);
//    
    NSString *wifiReceived   = [self bytesToAvaiUnit:wifiIBytes];
    
    NSLog(@"wifiReceived==%@",wifiReceived);
    
    NSString *wifiSent       = [self bytesToAvaiUnit: wifiOBytes];
    
    NSLog(@"wifiSent==%@",wifiSent);
    
    NSString *wifiBytes      = [self bytesToAvaiUnit:wifiFlow];
//    
//    NSLog(@"wifiBytes==%@",wifiBytes);
//    NSString *wwanReceived   = [self bytesToAvaiUnit:wwanIBytes];
//    
//    NSLog(@"wwanReceived==%@",wwanReceived);
//    NSString *wwanSent       = [self bytesToAvaiUnit:wwanOBytes];
//    
//    NSLog(@"wwanSent==%@",wwanSent);
//    NSString *wwanBytes      = [self bytesToAvaiUnit:wwanFlow];
//    
//    NSLog(@"wwanBytes==%@",wwanBytes);
}


@end
