#ifndef __bool_true_false_are_defined

#ifdef __cplusplus
	/* already defined */
#elif (defined(_MSC_VER) && _MSC_VER >= 1800) || (defined(__STDC__) && __STDC__ && defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L)
	#include <stdbool.h>
#else
	typedef char _Bool;
	#define bool _Bool
	#define true 1
	#define false 0
	#define __bool_true_false_are_defined 1
#endif

#endif 
