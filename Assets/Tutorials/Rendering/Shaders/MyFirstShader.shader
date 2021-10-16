// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/MyFirstShader"
{
	// 这个属性是会在 Material Inspector 中显示出来的，用于交互的面板
	Properties{
		// 统一用下划线+大写首字母的格式定义变量，这里的变量仅声明，不需要逗号分隔
		_Tint ("Tint", COLOR) = (1, 1, 1, 1)
		// 这个属性名称可以在脚本中通过 Material.mainTexture 来获取， "white/gray/black"可选为默认值
		_MainTex("MainTex", 2D) = "white" {}
	}


	// 多个 SubShader 可以指定在不同平台上的渲染，或者指定不同的层级渲染
	SubShader{
		// 一个 Pass 对应一次渲染，多个pass就是让他渲染几次
		Pass{
			// 一个 CGPROGRAM Block 表示一个用于渲染的程序，因为有别的不用于渲染的程序，所以需要专门指定该程序
			CGPROGRAM
			// pragma是标记，告知编译器哪一个 function 是 顶点渲染，哪一个是 片元渲染
			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram
			// 类似C文件，添加必要的文件
			#include "UnityCG.cginc"

			// 这里的变量会从 properties 中寻找
			float4 _Tint;
			sampler2D _MainTex;
			// 这个属性比较特殊，他并不是从 properties 中定义的，而是 2D 数据在 properties 中定义后，
			// 他会自动给你分配这个属性，比如 _MainTex 定义为 2D， 则 会有 _MainTex_ST 这一属性出现，他表示 tiling and offset
			// xy值表示 贴图的scale，zw值表示 贴图的offset，这四个值用在计算uv坐标上
			float4 _MainTex_ST;

			// 定义结构体，方便传参数，对于结构体中的值都要指定 semantic （就相当于存储这些值的寄存器，索引这些值的时候用到）
			struct Interpolators { 
				float4 position : SV_POSITION;
				// 一般把额外的属性都放到 TEXCOORD 这类寄存器中
				// float3 localPosition : TEXCOORD0;
				float2 uv : TEXCOORD0;

			};	// 注意，这里往往少了 ; 就会报诡异的错误，比如 reDefine xxx

			struct VertexData{
				// 输入的顶点坐标信息（原来的世界坐标系 [-0.5, 0.5]^3 ）
				float4 position : POSITION;
				// 输入的顶点uv信息
				float2 uv : TEXCOORD0;
			};

			Interpolators MyVertexProgram(VertexData data)
			{					
				// POSITION 这个 semantic 表示输入是面片的原始顶点坐标（semantic类似寄存器的概念）
				// SV_POSITION 表示输出到 这个 semantic 对应的“寄存器”那
				Interpolators i;
				//i.localPosition = data.position.xyz;
				// UnityObjectToClipPos 函数是将 object 坐标 转为 裁剪坐标	
				i.position = UnityObjectToClipPos(data.position);	
				i.uv = data.uv;
				return i ;
			}

			float4 MyFragmentProgram(Interpolators i): SV_TARGET
			{	
				//return _Tint * float4(i.localPosition + 0.5, 1);
				return _Tint * tex2D(_MainTex, i.uv * _MainTex_ST.xy + _MainTex_ST.zw);
			}

			ENDCG			
		}
	}

}
