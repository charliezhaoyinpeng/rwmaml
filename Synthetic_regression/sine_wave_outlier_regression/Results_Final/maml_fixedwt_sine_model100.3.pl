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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_fixed_weight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_fixed_weight.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2170082010064qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2170082010160qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2170082009680qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2170082009776q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2170082009968q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2170082009488q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2170082009488qX   2170082009680qX   2170082009776qX   2170082009968qX   2170082010064qX   2170082010160qe.       �ax�@      �]��`C0�C��<��@��`�=0�>fHS=�7�;M$�j�5����=]���	����U��v�C�,�y#F�0�ӽ��%>���8�Y�;�xG����������	�=YBD�
{�=�����20��i�=Q����:��;���)f���g�<pA�< ؉��b�>MЅ�K!ɽ; r��c�>a�Y��dQ�J.E?�N��bP�=2~��i>�������ht!>CFw� ��6��>�*�������^��m��>7���n���ҏ��w(=�%��e7�= ���̀���۾� 
�f�Ҿ�M�[�A=�
���y�=dN��f6�>s��Iu���x���K?��,>�T>d�|>���?������ݿ�����?fL.>c��Mf����y��Ȅ�IO�-�>z��>k�?�O��I���� >c&ƽ�9>��y�B�>Oh(���׽���=��p�vu*�ь½͒7��I���o��^����?K��<E��2+�A=W��@t���Io=���Q��<eX>������ڱ)� �3=�~�=� ��(]=�I��x~�wJ�<r13�0��=e�K=;���=o4G���
����=P�1��a�=G�=މֽd�~=f6s�;� M<��b!�*��5��鏡�e�h�DD
�BT��0ш�)VW��<>��L>���Kl�����,�={�m��IU>5�����?x+߾>��=�C-?a/�>!�׾7ž:g>��?P�=b�*� �h>�������>p;���iq��Q&>����T�>VJ��x>wh�wv{�@�R���Uݽ(Ǽk*ͽ>x�&�,������Ԡ=x�.�c�Q�_�>�UC=�C�=�m��� �=�_(=>�>��F���sQ��{���ͽ.<o��R�=~5;���)�4ǽ��[<�;��ҽ�$�c8�5]>Rk�Ћ=8Zn=�`o�����7�^M�={��p�l<�ۍ�P}�Y��@��;�a�Ey��j���>�鈾@����	`�`��;
>��=�������½�'ҽ��<0���;��!=�+���=�Q»r3�r�]�Ej;�s���νvG�=��=�����%�=,<���5>�������x,��Qнx�7��c˽�`���EL=QT#��^�i��;�轷���與�b샼�ٹ��,�8*Y==@<&�R�X��<��I��m�����,�=�O��.�"d��@"�=�r�+���؆=��|b�b�;�,��$gp=�2��s��� �����"�y��x>�G(��녻s�R�!`Q� �|���=�m�����>ߤ4�EF|��������U4>%�>'�U>����U���.|7>���L*?Vt��H���@��}a����=GH.����o{˿0Rƾ��=�p�<MQ@�3+������L̽�U�> �*�y���=p|<�c�l�KeϾ��w�f����:=>�=�G�=��4<����,��=0��=�O�=���=�ɯ�g�,���0�-*>kh�=.�1��9��W<������7>ɽ4=����l=��ݺ�猽�b���i�<7�-�������= �f���=���=$�=����<V��e/�ԩa�Mc��U���ً��=ަ�;�����MQ�/�!�/h��d�����3���f���� �ax&>�jB��^ƾ���>t�=�ID�3/޾�[���7?�I���������:�ca?J����m��h���0� ��W��旾&6��� r���y�1��x���+о����;��t��=v|�6}�?a�>{���SQ>��e�8i�=@x���g>���@ˑ>�H;?ht��o>V���'	p��4�U�?���x�����������SW
=g��m����������>3��=�z�>5�>�F><����@_�֤����.�R�r��tÿ<W�=��;���������2=�L?/�P�nԼ=N��k >�Lľ�*�s��S�Wဿp �?�w���׾�ɦ��Xf��a�?򔍿,E�>'="��Y��2�����?ru���T6�����������
�ɾrTʿ^MV�^=�����=8�2<ޢ�PC<����J�0P�Vj�
���G̽�K����ɽ�+̽��=�鼀�t�������=Dz����R��������a�0�|������=x�+=���=���=��:��;�@� �Y�=��QO����'�������q<��
� h�rW���e>�84��􎾽^/?�1{���K���!�Y����iY���EϽgi~���H>��վ�-߿�_>���?�$�>]����H>���>�����?ӿ��r��M?�4$���m=l�?�!a>�>`�c>�aԾ��{�)���CԾAҾ�"��E~Q�κ=7��=q&�q����T�=������>h���oM.��z3�z[>���$��`n�qo�>������C�Ui?
9���������_��Q�=Mv�XШ<��!?L�Լ@�0�B0A��E}�R�>g�d,�i�Ӿ�;u�����,�U��=1O	=�b,��p�=�T��``�'?Y�ڶT��O�> G�~��@�^�PU������=-6<��
>>���̎='��_���+TI��9=��>e�۽�cE���X���t� ;��Ԡ<Z����<V����R*�w����%���9�=�*���i�ON=-Ӂ���1������J�������I���ҽ�����&���"���v6�S���+;ݾ��H?5H�c��=]�>���³��O־箾�v��L�?�	�?D"��2�������u?A���� ?s���=�� �r߰��"��kM�u�ܾ1���$�7�"���������ľ�I��mT�\7
�R�>�;<zؾ��<=bM�=��<�\0���f$����=�,ѽ�E�̒���l9�[�v=a%O�)E�<��i=$��#�1=�D�I!���#����c� ���ؼ��ؽTq1�H�_��O���e>���=uL_���|$o�f�N�H]=�!=�Ծ�>[!���y���$l�w��̫?PI����?PϼK�ü��=B��= �о� �>�>�\����>�P���[��^�\���6ð=�0%?�n������ž4�3>�}	@@���烾6Y��l�	?��>`�o?fv{?,�=L[��F�<��A�n컬��>џ�������旾�忼����:>6�e?N�n�8�V>e�����T�<�2>(Ե��R�j�H</S��0e<?�<]����M��r��U���p��˿>�F=R(�>
ux��c��F>3��>,$�$�ľB6 �q�����V>� |�;ٮ<[���3�`��ȯ�u]S�G���g�� ����C�=_�=ܗ�!,��ؾF�;�4�꽉A�=���#���x>B�<z"���=�1�%�����r=^̾j��
��R�f�{ԋ�ȗ��	W�V������@��X�=�>���czҾe�+>�}��gF8���[�Q�;�Q�>g 	�F-P������m�K>�m󿹿���+��}�=���:��<}֗��e����=�0?�����h�e?�<��zM��.+��S�0�<G���<���ӽg�>�뮽�i�2l��)�\�	��
>o�=��W=uz�>;D�������P�h��s�?!���cx�05>?if�Au�]T>S�?�Y��u��k�F?���4o��⽿��>F7�>�&B>�V��r2�H.?���h�>Pn��?<�����.<a�R	l�4󋿰4:�F{ӿ���>����H�?j�Z>�
��'����Y�l�F���N��S����jI��	H����T�;�R�~9���/ν|2�+��������?xN���/��3��T;���k2?�خ��|����O�g����?���櫾�+��
�� =�����h+M��ў��|־`�9�;���{�����.<���ƪ=�Z����޾m�C>�c�v.�>~>�߬��+��ĝ<�4˵>����}R�)]������>��m���e�>I��>ӏ�*��@�)����;D��J�#?�-��rf<�g�U��F�>� ������u<1���A�>���J���G���a�Sb��o_��>���>QZ��ҝ�?�3$���뼜�+���>�1���i>e�h�R��.�L����<����^��S���=�W?|���H��Fށ�0���D�'�]ڴ;پ��ɽE�>�� ="B�>? �j��q�0����@����	���˿��̱¾f�>?`��qّ>`ʂ<1M�>4�>�MF�@,�UvN1��P?�����_����!����?�!�{�=��>���f����C�CF�?�|��d��s��o����f�Y�&��;>�ɒ������2?Z�뾐���)�i�M�P�{@�M���.�=��u��.��d���?=������K�q�������e�>��o<�)�<~�=z���_6> 7нO1������p<�KؼJet����H�����*ߛ�	cI��g>��Q��-�mK���
��� �=�������2����$��"��rz��6߾��n?2[?�)�>�����=Jʞ�J�{���5>��"]Q�\�"?���>	�³�>EJ�u��ަ?�LS>�����j�k9��EĽ������.@ٺ6�xf��bƾ��j���Ow>s�?A �����Ϟ���%����=d�?�訾3Z�=<���m��>!5��Ќ>���"�c��>H�>�c�Vx�>���p�g?os?;?�˾I��=�8��-���j>�R�>���=�ټ��F���Ĥ>�u׾_e���5?�o>�r��s�=0�ޚ��Ke�>�<?Px�<��>��U���%>YH��&�>��N?�6@���7s��%�>G��[�>@"x<����p	;�w���΍��;������
C�>���=�>,�?��><���T��H?����H�>Kϖ>�ZZ>]R}�'�0�����@�½���m7�%�>G����>Y� �:�h�!�9�=�af2�����R�ݾqjC������>B���)�3ݳ�0�i�`�����1=�B��00���e7=�3�<��=h����4G�dx0��E��'�H�֘���=c�d���㾁˦��&��������3P�����q�S�*�=bP�� 鈾�<+��S�~8��!̏�)�u���[��o�?5��>�PL?,cʾN���k�񽧑��"��=h�=�#.�7�;?��⽚-[�RI?�Յ>}C���?�� ����������bn��2��t��8@5g;�냾��b�n�=�c==�v>���?�3[�������Ͼ�,
�tTŽ����Q�;s`"��L��J�,�W=k��*L=j�S����R�>���Խ�&�������P��?νG1��/�dS��Ea�=����U�=�D=
�h�C˅�!��Q�<5�?µ�-����դ�\�x=�졼�"��~k�=Z�:�zrU��ϴ�-8�=��=��5��=�&��t��ٽ[�üG ���yy=����f��hh��P伐�j� �P�:����<ۋ���N���?��M�=}aZ=��I<�L:��=�����l	�<���i�Ƚ�;=(��<%���C�但3t=d��@�P;Q\=�B򽒍k�{�׽~���c�<�J��d�?q� ?["����?C���A�����Q�����(&��W�=���9M��B�������E��2��o>��>�<���E�=���w��=f��m>{=�W־C���1��>a��=���>�F1?!���TD��f���Z�l-%����<������3����</Y�=�H½ �����<=�k�=�	�=���<�Q����~��}s=2'$�B]m��_�����K2=A��RM����e��8�L��x���%=��=�?������bLT�H$f=N}�=���=���m�=8�A��̘�׉T�0�<���b
��w��60�=�+�>�˽YHĽ[����?��JѾ�1ǽ�9�=�����Ծ8��.|���*����C���dW�G�P��ST��%�6����}E�4兾"�FcN���1�� �h���u�[���4����d=�3x�4���J���ϣI���a�:J�<.x�uǗ�8�����/��[��߭>`pK�՜��6	��x��?�?��>�?1�5���_�=�K��>�><9�=��m��X����>utj?@�+����W������k?�d���f>3,�� ��>��7�!���ո���9z��ճ�>(       ܗ,����A&�>����ku<�f=��� ��$�/�Hv$�UB<�ڔ���?�����+�ݸ�;�"d�׍�>7^�;�����=��/)����
En>�þлѾ���gX?�0ܾ�Z߾�B�^����z�j�Y�_pL�C��*�5l�2��ת��(       B�	��ϯ?��+?v�7<�<��
�=)�ؽ,�=��b?=���͘O@Iz�>KK?��Ƚ!j'��7=XH������RG>�f�>7�h�6?��K}=�J�`��X?�W�>�~�?Q��<��?fK?�~-��D���N>�~��k�	�>AD뼚�=j'�(       }��<6�>1�J���>����J�<�F$?rD���z=�)�6
�� ��G-�>���>ŗ=��L�82�S5�	�q�t���2�+�A�>�1�������֙����?_�B=��>�`_�v���*�>?ň�>;"?�?9P]��t?�ؾ(       '^=�`��H�<�hp��{�>��P>������->bG�&�F�,��Z��S�\����e>�;࿼��=(?�׏=ϓ>(D�����@?�FX>���>W��=3���\&�=KP���������cT������#��-�v{�<������