#include <Foundation/Foundation.h>
#include <xpc/xpc.h>
#include <sys/stat.h>
#include <assert.h>
#include <roothide.h>
#include "launchctl.h"

NSObject* xpc_convert_to_nsobj(xpc_object_t in)
{
	// for (int i = 0; i < level; i++)
	// 	putchar('\t');

	// if (name != NULL)
	// 	printf("\"%s\" = ", name);

	xpc_type_t t = xpc_get_type(in);

	if (t == XPC_TYPE_STRING) {
		printf("\"%s\";\n", xpc_string_get_string_ptr(in));
        return @(xpc_string_get_string_ptr(in));
    }
	else if (t == XPC_TYPE_INT64) {
		printf("%lld;\n", xpc_int64_get_value(in));
        return @(xpc_int64_get_value(in));
    }
	else if (t == XPC_TYPE_DOUBLE) {
		printf("%f;\n", xpc_double_get_value(in));
        return @(xpc_double_get_value(in));
    }
	else if (t == XPC_TYPE_BOOL) {
		if (in == XPC_BOOL_TRUE) {
			printf("true;\n");
            return @YES;
        }
		else if (in == XPC_BOOL_FALSE) {
			printf("false;\n");
            return @NO;
        }
	} 
    // else if (t == XPC_TYPE_MACH_SEND)
	// 	printf("mach-port-object;\n");
	// else if (t == XPC_TYPE_FD)
	// 	printf("file-descriptor-object;\n");
	else if (t == XPC_TYPE_ARRAY) {
        NSMutableArray* nsarr = [[NSMutableArray alloc] init];
        
		printf("(\n");
		int c = xpc_array_get_count(in);
		for (int i = 0; i < c; i++) {
			NSObject* obj = xpc_convert_to_nsobj(xpc_array_get_value(in, i));
            [nsarr addObject:obj];
		}
		// for (int i = 0; i < level; i++)
		// 	putchar('\t');
		printf(");\n");

        return nsarr;
	} else if (t == XPC_TYPE_DICTIONARY) {
        NSMutableDictionary* nsdict = [[NSMutableDictionary alloc] init];

		printf("{\n");
		// int __block blevel = level + 1;
		(void)xpc_dictionary_apply(in, ^ bool (const char *key, xpc_object_t value) {
		        printf("\"%s\" = ", key);
				NSObject* obj = xpc_convert_to_nsobj(value);
                nsdict[@(key)] = obj;
				return true;
		});
		// for (int i = 0; i < level; i++)
		// 	putchar('\t');
		printf("};\n");

        return nsdict;
	}
}

void xpc_save_to_file(xpc_object_t object, char* path)
{
    printf("xpc_save_to_file to %s\n", path);
    NSObject* nsobj = xpc_convert_to_nsobj(object);

    assert([nsobj isKindOfClass:NSMutableDictionary.class]);
    
    NSMutableDictionary* dict = (NSMutableDictionary*)nsobj;
    [dict writeToFile:@(jbroot(path)) atomically:YES];
}


#define __GNUC__
#include <assert.h>
void patch_plist_file(char* path)
{
	xpc_object_t service = launchctl_xpc_from_plist(path);
	if(!service) return;

	bool patched = xpc_dictionary_get_bool(service, "__Patched");
	const char* Program = xpc_dictionary_get_string(service, "Program");
	if(Program) {
		assert(Program[0] == '/');
		if(patched) Program = rootfs(Program);
		xpc_dictionary_set_string(service, "Program", jbroot(Program));
		xpc_dictionary_set_bool(service, "__Patched", true);
	} else {
		xpc_object_t ProgramArguments = xpc_dictionary_get_array(service, "ProgramArguments");
		if(ProgramArguments) {
			assert(xpc_array_get_count(ProgramArguments) > 0);
			const char* arg0 = xpc_array_get_string(ProgramArguments, 0);
			assert(arg0 && arg0[0]=='/');
			if(patched) arg0 = rootfs(arg0);
			xpc_array_set_string(ProgramArguments, 0, jbroot(arg0));
		    xpc_dictionary_set_bool(service, "__Patched", true);
		}
	}
    
	void xpc_save_to_file(xpc_object_t object, char* path);
	xpc_save_to_file(service, path);
}

void patch_plist(char* path)
{
    struct stat st;
    if(stat(path, &st) < 0)
        return;
    
    if(S_ISDIR(st.st_mode))
    {
        NSURL *dirURL = [NSURL fileURLWithPath:@(jbroot(path)) isDirectory:YES];
        NSArray<NSURL *> *plistURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:dirURL includingPropertiesForKeys:nil options:0 error:nil];
        for (NSURL *plistURL in plistURLs) {
            // contentsOfDirectory always return rootfs-based paths
            patch_plist_file(rootfs(plistURL.path.fileSystemRepresentation));
        }
    } else {
        patch_plist_file(path);
    }
}
