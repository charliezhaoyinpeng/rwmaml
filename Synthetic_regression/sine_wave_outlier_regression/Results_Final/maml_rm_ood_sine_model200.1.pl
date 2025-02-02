��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_rm_ood_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_rm_ood_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   2130491606768qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2130491601392qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2130491605136qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2130491604752q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2130491601872q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2130491601488q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2130491601392qX   2130491601488qX   2130491601872qX   2130491604752qX   2130491605136qX   2130491606768qe.(       X� ��|"?�Y�=LR>���C���Y�<˼�>�c��?o����B@�؉���g��ϝ���x�-Q��\�
=�)����e��D ѽ>�l>r�@�=*�����=��<��xg=���>��ȿ��=�zD>�:�;�>K�5>D��Ԃ<<�C�-���       ���(       ��?|o1?~+�߆=�y�� �!?9� >��>d�?��>�w��;C�͊_>?�>/��K�%��=��,>�w�>O� �,{ @���ao�;� �i���1�Ǿ	N�>�9s�/2Z?(�׾�(?���c�q�6!,��QZ?��C?e�;�Q�<��(<G� �(       ���k����5?/�0��,u��A$>:i�10߾@�w�C礽u�d�9�����˿�>��>`���]��c��<P�ͽ�x�����?����ؽ���?���(v�>O�X|o?��=0v-�0ϿA�������,�?�֧�&F?��%<d��=�xF�T��>@       ~�vzW?]bJ=��½�4.>Ÿ��]�����=�IQ>Hޞ���=��ſ9M�=��0/q�k�>���%�?(`9��嶿��=L���/����z>�g�<���ml��IT�'�=�( ?�ֻ��N�k�U�l�(�%�D=���>��S��/�?_P!����==P�4�}��XZ>o��>|����+?���>S`��A���l�=��V�C��<WR�c�?^C�=&��J��
�9���>��6����>��x?���0�g?�=�>���>���>��>��a�*~?��=|-S?�
�>��U��B�;P�8�� %t=u��>6#�=����=�5�>�{�^�?б�>�KN?5�Q���]>�q����>��S��K�G������O��-k>�%�s�9�ۍN�X�>$7�;�I"�we >EG>Wʽ>�0>�[�=���>��<c�>${?�T��V��p�c><��|����=�����e��������C-��8��r���##�xD�]���l��@�r;��x=YS_�.�=��>gk6���Ƽ�:���3ؽ˴�\���r�Խx��@&=,L��������h&�j����d�`B���f�=H�N��Ͻy�G� '���~�Ik><פ����ǽॳ=�(=7����`��:ӽ$~��k�5����<���<�_Ž�K¼�a�=>��=�(������={�ͽ}`=�`>����P�aH�=����c9���=���C��|Lܽ^�鼷��Ƚ˴]����I�<�F�뎺��r���=>��v=��Խ�=s��?|��������ϯ=Ty��?k˾lgz�&O�����Iѿ�Ӿ�j��yv��D������L�ͽ,���࿧��K�;iA�>�c����>�w-�����ѽ�C?�~�>�p�OpP��i�[5��f,?�L�=�|]�I�>��q�jI�x~
=���UA�?��/�W=<|��VU?�t>��>4��A7L��䱾$o�=�p>�w���N>�k�=��>��b���Y�>6��a+G���:<K"��9�>gת�>̔�N��i�=� �$�����V��+߾��������">I��>�>��; ���e��0�>dl���s�e��		�>�k�>B�>��)�usW��_���!=�T�>i�b��MἩdC>�Ϙ��{>�x����=Xx]�I�?�¸>�Oi�9�������삽�� �2��>�F�;��(�#?
 ���<\c�=�W�l�
�&�6p��0!��������n>7[���u�8�ӽ��=�2�a��^E�Gy1��#���l���<��=_ ��ڂ��*��>���j�ν{V��d;r3���M�Sļ��}����짽����m=�1>5h;>U��?MI�>X�0�nv��O�i�W�7���>	�=f�޽x�.=8����m�z맽B�)���6��'�M�;�fS/�[��/.��BF���gO=���'8F�#���EM�t-="���`�ֽvа�����2�� 5߽�<��-�<��>�I=�[�=\��<]����2ѽ��B����=2w�dX4�2�=�vE�͒����B�a�����'�;��z��35�"�b�Ʋj=^O˽�\�=���<���������Ƹ�avս�Y�C'�=����G+��o�=<ܼ��^��r�s0�����.'��y`�r��,X�k��<�R��N���R]�*�b���!�N��w�?;i���f���R��葾~��Sھ�mr>�n9���y����� =h��>�Aܾ��6>�	?��A��>?B`�ԙ�=�rB�!�%?��=�����䴗�A����?�l1���=����2g�0Ɗ
>f��F��>�b�>�܂=kx�� >�ٿ���>��h�gCU��������<������Od���Cv���m=rB����N�>X@<��u{�?>��;�t�=�_�ڕ��I�f�нT罩��r2����<ط>{�$��U�>5�O=��?���>h�T��g3���R�^7W@�,��:��>f٩�X�ʾy�?���������f>Yӟ?.T1?ﺮ>"g�>#���[��ϼ�=���=@;���2=�.�?yD4�� [�͕�>����\�?�V>G&�B��=������n>��-?9���V���J�@�x�U�l�U��p�=�G<?v�;>o;��Z�+�>~X�?��a�F臿M�D>��3?9B?�������>#����lv�<�)>I-�7�����>D�&��7?R���+��������V�G忑0��a�!�Bl>CsɽC>3�R>�2k?�j�g�?qgG�R�~�s���͎�	\=�3Y?�I>����~��{�����1?_L��4�ı�>�?�s?�.c�� ?c�����־��m���A�Fg���Θ�@B��?����@,����'>{Z��m�����>F¥�P?$䑾��^?ʙ�����?#{���?ѽ�bV�|�S�ߛپ?:}>��.����|ؽ�L�<�ӵ=0��������?�)=�wu;�n>�<��6��j"=w2=᱑���<�BҽX�	��1��Z$�8���=���6H�=����� ��]޽�R�=��=�M-�=��ֽ�-ý�Ͻ�������=�A���<���=u5��ɽ���ؗT=�@�={͝�䂽��6�
�=f ��ν��=(�/;����E�<��ڻ5���@=ƼJ������=۶��>>�c<Ez��]���VY%��쓾 zX�޸�d����4�=�ˡ�������=}�#��<�;��=Y�7��r$ҽ����y�c��;?���C�UP��T�>��L��jh�𥁿�L>�Ѓ���I���.�,䷿v�m��`������ns��'���Ͽ1���w��>���>�뽿!�?G">��N=J�>�x�>y�(��;¿�Z���X�ǿ�7?���>ﲙ���?�p>>�m� bq=Ɨ>�&��6�޿�$;�7>�y�A�����%9=|>���s���f6=}����x�=����2����
������ɽ��"�C����s6?�!���3>���<�3S�"C�=��?
� ���~>(�������ټ�6>^r��G��b���6��f�ٽ�����!?��>?�Ћ��R�&&���iU�t���D�ů!�9���r���K*��R�����5�5�A@��w�1нew���3��\>,7������@��)?ƞĿ�.������$����?��U�ڇ�>^�>�N��;)?b���j�o"�k��5 ��5b��T��oc<;�߽�)�=��ZT����0NQ>��W��푻�Gڽ�K��y{>�rP��=�	>�潕�2�ƌ�8ɽ �x���\dS��K��5i��y���̹�u0�����=�bs�p����c����Ƚ��Z
�l��t ��Є=X�x8������۽�,�����=�`D<�#��Π�=L�0�D�(���&�5�n�	�����TR=��5����f׾=�<=�'��V�<N�4���g=��~�����_P�J��=A���jϽ�<ŽuR��;o(<&���b�N="�=#� ��h���T�=���"w(?�O ?X��>�"a>�k;?~�!���9�����§��U��3��㾸�;�r��ys�$�c��������>�uL=��-�6��>@bq<��>�,6=<Va��k����8�?�r?��x��w;��pH>����I���!����<>[�=+9?A�b������0��yp�����������<j�;����I�<��t>�>�X�:�JL>̾��_H>p �ݥ�^��W�t?�[->����L��Y}�4� �?�}�����>�*ھ[�=�h�>��>��O��>�͔A;��>=����i>F���L1�\�W=L>.�t�޽���ܣ�=��u��9>kNH>l�<������U�Y��}��WǞ>���;��L���E�|�؏�>UU�=�M��=�5&��5<�h�>�`>��r��9���ξ�����<���U���/�UeV��Խ�c���%<2a�o��?� ½�������'>�(-���<��'�U
 ���ʿ�A��d{�=ZGj���C>���=13�:3M=��=Q{�=l��V4߾iY>k#���=Fè����=��=Ų�>���>w��>)�>f���7��e��<�iھ����G>�r�=�T�͟�=!����Nܾ�Y�=[�"��.�$y���>ċ̾�~f��&�C'�ݜƽ��强o�<��>E�<>����z�r��`\=�V6=-�ս�x�����Ƽ
��ѽ�ԓ�R��Հ%�t1�Ht|�t��=o�>�$�>��=;��eٻ�Qe><�=THn?���=�����v̾�kt�-{��ž�\ ��jp�@W%�����g����v��Aw^���a��
�<@�� �x���˾���s��7�=�h��;��13��>��`�.�·i>*�>�ဿH��� ���T��f�>)> �4�J��?K`}�ű<�+�	����?�/��ԩ�<�L�ǣ>��N�i�пA�ᾏEh�y"���b���R�>�w����='������7G�?%p}�b��=� 3�&�2>��MU¾{3���#~>���<��>W
-?�Z�v2�>��ܾ0[��.?l�> �|�R�f=¤?
�m>1U�> �c<ѹ�3��?&���V�b��=��>��>{�>���>���8��X>> �>�u���>�؝>�7C���w>��>�;*��=��侮��>�����y>�IU����>ĳ]�l�Ƚ��ƾ��
��S/?�W����\�k�'xn>.b>�*!>�g���S�24W?��k��-���%��uÍ>8�8>��<|��ep=�ӭ���½�<��&�{&>�E�������?�3�q�>8�.��ټc�|�����vu���%x>�2?�d��>�"?#v�?u �=9�}=XG����>M�v�8�=�A�#��-�?D��=S��<����7�>���??�S�ֈ�yX^�މ�>N�
?�U����=����p���:>v�>,�>l>էw>�����>n>(�>����[����ܾT=��0�D��Ъ�C���E�R�[?��G =?�����㞾���X��n�>����^9n��O½Rޣ���?r�1>���ݧ����>҇�>z���C��l�S�v�K���s���	�<,߾Q�dG���A���8"�|U����4��>��1��ގ>����>�K�v�ܿ�䬾E����I>Z�^?<�=Tw>@t�>z�����4��5FR>3�	���$>BC)?��>ך>������8?#�>Jm>���;�SW>���K~�=��5����ۄ=|/�[�,?�0����u�=��@��^��,G>W��6>��O�¶#��m�=K��>eѼ̈́?�~��@x�>F��AuE�K}�H��>��=%?�C�<de�?�l�%ޜ�D[>[�Nϻ�Z���p�n%��>C8�����G��׏�����㙿��p=}ٿ������>�d>V�����$�x��j����9�C��{P>��V>�蕿 疾S˝�����jU?_�?x����� �{潾+����E��-'���m��b>����;�,�� �<A��F��=]�r�����0� =7^�� �<�� ���p=���=<�v�.+�=��=w��=|�=��������8�?�k6>�z��V�{�<����jٽ�1ѽm+<����=����=�E>}��s�=���𾧽)xp� �˼����p��F6�C�x��K� wн`�=<�R�=��>�Һ�=�Z��]"=#:S���f�=#Խ��E�I�<ޛ���,�"�7=%U?�H��=�H��bn������<Tۋ=��h=�Ὄ���>�Y=8���-�*�q�=؍�̆�?�ኼ�ʟ�������6��<1>Vl�=&x|��D��>ѥ��7=��\�����6z�=��� 	�ܚ��'V�<����}v`���=ȣļ�_u=y��<t��6h�=z�����;��н<吾󡚿����N>���</��
W����<s��.�>�[:�d��..�����II��tԽT]ӾC���8ɿL��*3��4(��۾��@3�˾V'�'��2B�=�Q?��ľ-0?�3�u:���aN��Pw��Ϳ��R����=�> �Q=,g�>g�`>����$�?��N��?(       �����ƻ�t�H%���������<�0r�}�1��B8�F�ѾժN?������K�\?��b_����ա��6?rM�dNR��%�<�)�����lY��#�z�B���)�]cP<��k?W��=�)J�0?�o�=���=��P��<�վ��?