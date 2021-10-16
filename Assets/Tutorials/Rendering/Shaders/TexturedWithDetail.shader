// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/TexturedWithDetail"
{
	// ��������ǻ��� Material Inspector ����ʾ�����ģ����ڽ��������
	Properties{
		// ͳһ���»���+��д����ĸ�ĸ�ʽ�������������ı���������������Ҫ���ŷָ�
		_Tint ("Tint", COLOR) = (1, 1, 1, 1)
		// ����������ƿ����ڽű���ͨ�� Material.mainTexture ����ȡ�� "white/gray/black"��ѡΪĬ��ֵ
		_MainTex("MainTex", 2D) = "white" {}
		// �洢ϸ��ͼ
		_DetailTex("DetailTex", 2D) = "gray" {}
		// ����ֵ
		_Brightness ("Brightness", float) = 1
	}


	// ��� SubShader ����ָ���ڲ�ͬƽ̨�ϵ���Ⱦ������ָ����ͬ�Ĳ㼶��Ⱦ
	SubShader{
		// һ�� Pass ��Ӧһ����Ⱦ�����pass����������Ⱦ����
		Pass{
			// һ�� CGPROGRAM Block ��ʾһ��������Ⱦ�ĳ�����Ϊ�б�Ĳ�������Ⱦ�ĳ���������Ҫר��ָ���ó���
			CGPROGRAM
			// pragma�Ǳ�ǣ���֪��������һ�� function �� ������Ⱦ����һ���� ƬԪ��Ⱦ
			#pragma vertex MyVertexProgram
			#pragma fragment MyFragmentProgram
			// ����C�ļ�����ӱ�Ҫ���ļ�
			#include "UnityCG.cginc"

			// ����ı������ properties ��Ѱ��
			float4 _Tint;
			sampler2D _MainTex, _DetailTex;
			// ������ԱȽ����⣬�������Ǵ� properties �ж���ģ����� 2D ������ properties �ж����
			// �����Զ��������������ԣ����� _MainTex ����Ϊ 2D�� �� ���� _MainTex_ST ��һ���Գ��֣�����ʾ tiling and offset
			// xyֵ��ʾ ��ͼ��scale��zwֵ��ʾ ��ͼ��offset�����ĸ�ֵ���ڼ���uv������
			float4 _MainTex_ST, _DetailTex_ST;
			float _Brightness;

			// ����ṹ�壬���㴫���������ڽṹ���е�ֵ��Ҫָ�� semantic �����൱�ڴ洢��Щֵ�ļĴ�����������Щֵ��ʱ���õ���
			struct Interpolators { 
				float4 position : SV_POSITION;
				// һ��Ѷ�������Զ��ŵ� TEXCOORD ����Ĵ�����
				// float3 localPosition : TEXCOORD0;
				float2 main_uv : TEXCOORD0;
				float2 detail_uv : TEXCOORD1;
			};	// ע�⣬������������ ; �ͻᱨ����Ĵ��󣬱��� reDefine xxx

			struct VertexData{
				// ����Ķ���������Ϣ��ԭ������������ϵ [-0.5, 0.5]^3 ��
				float4 position : POSITION;
				// ����Ķ���uv��Ϣ
				float2 uv : TEXCOORD0;
			};

			Interpolators MyVertexProgram(VertexData data)
			{					
				// POSITION ��� semantic ��ʾ��������Ƭ��ԭʼ�������꣨semantic���ƼĴ����ĸ��
				// SV_POSITION ��ʾ����� ��� semantic ��Ӧ�ġ��Ĵ�������
				Interpolators i;
				//i.localPosition = data.position.xyz;
				// UnityObjectToClipPos �����ǽ� object ���� תΪ �ü�����	
				i.position = UnityObjectToClipPos(data.position);	
				//float2 uv_st = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;
				i.main_uv = TRANSFORM_TEX(data.uv, _MainTex);	// TRANSFORM_TEX ������ʵ���ľ�������ļ���
				i.detail_uv = TRANSFORM_TEX(data.uv, _DetailTex);
				return i;
			}

			float4 MyFragmentProgram(Interpolators i): SV_TARGET
			{	
				//return _Tint * float4(i.localPosition + 0.5, 1);
				float4 outputColor =  _Tint * tex2D(_MainTex, i.main_uv);
				outputColor *= tex2D(_DetailTex, i.detail_uv) * _Brightness;
				return outputColor;
			}

			ENDCG			
		}
	}

}
